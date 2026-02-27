using Microsoft.CodeAnalysis.CSharp.Scripting;
using System.Diagnostics;
using System.Text.RegularExpressions;

namespace AssemblerWorkarea {
    internal class Program {
        static void Main(string[] args) {
            var assembler = new Assembler();
            assembler.Assemble(@"Test.asm");
        }
    }

    public class Assembler {
        private void DebugLogging(string message) {
            Debug.WriteLine($"{DateTime.Now.ToString("hhmmss.ffff")}: {message}");
        }

        public List<CodeLine> CodeLines = new List<CodeLine>();
        private Regex HexRegex = new Regex(@"(?:\$(?<hex>[0-9a-fA-F]+))");
        private Regex BinaryRegex = new Regex(@"(?:\%(?<binary>[0-1]+))");
        public int ProgramCounter = 0;
        public int ProgramStart = 0;

        public Dictionary<string, int> Variables = new Dictionary<string, int>();
        public List<byte> Bytes = new List<byte>();

        private Dictionary<string, Macro> Macros = new Dictionary<string, Macro>();

        private class Macro {
            public Macro(string name) { Name = name; }
            public string Name { get; set; }

            public List<string> Parameters = new List<string>();

            public List<CodeLine> Lines = new List<CodeLine>();
        }

        public enum PhaseEnum {
            Loading,
            ProcessRegions,
            ExecuteCode,
            ExpandMacros,
            Collection,
            Allocation,
            Optimization,
            Relocation,
            Assembly,
            Output

        }
        // ExecuteCode
        // ExpandMacros
        //    Collection = 1        // collect all variables, labels and regions...
        //Allocation = 2            // Is this for reference counts and optmizations?
        //Optimization = 3          // remove regions not referenced in allocation
        //Relocation = 4            // run through the code and find the actual bytes that would be emitted... branches, jsr and jmp will be incorrect but will correct in next pass
        //Assembly = 5              // This will be the final pass that will have the corrected values. bytes will be emitted here...

        private void AddUpdateVariable(string variableName, int value) {
            if (Variables.ContainsKey(variableName))
                Variables[variableName] = value;
            else
                Variables.Add(variableName, value);
        }
        private int GetVariable(string variableName, bool incrementRefCounter = false) {
            if (variableName.Equals("ORG", StringComparison.OrdinalIgnoreCase)) return ProgramStart;
            if (variableName.Equals("PC", StringComparison.OrdinalIgnoreCase)) return ProgramCounter;
            return Variables[variableName];
        }
        private void PushByteToMemory(byte value) {
            Bytes.Add(value);
            ProgramCounter += 1;
        }
        private void PushWordToMemory(int value) {
            var loByte = (byte)(value & 0xFF);
            var hiByte = (byte)((value & (0xFF00)) >> 8);
            Bytes.Add(loByte);
            Bytes.Add(hiByte);
            ProgramCounter += 2;
        }

        private Dictionary<string, Action<Assembler, string>> CommandFunctions = new Dictionary<string, System.Action<Assembler, string>> {
            { "byte", (assembler, parameter) => {
                var values = assembler.ConvertParameterToListOfNumbers(parameter);
                foreach (var byteValue in values)
                    assembler.PushByteToMemory((byte)byteValue);
            } },
            { "word", (assembler,parameter) => {
                var values = assembler.ConvertParameterToListOfNumbers(parameter);
                foreach (var wordValue in values)
                    assembler.PushWordToMemory(wordValue);
            } },
        };

        private Dictionary<string, Action<Assembler, string>> DirectiveFunctions = new Dictionary<string, System.Action<Assembler, string>> {
            { "macro", (assembler, parameter) => {
                var codeLine = assembler.GetCodeLine();
                var (directive, macroName) = codeLine.Directive;
                codeLine.ToDelete = true;

                var macroNameMatch = assembler.MacroNameRegex.Match(macroName);
                var name = macroNameMatch.Groups["macroname"].Value.Trim();
                var parameters = macroNameMatch.Groups["parameters"].Value.Trim();

                var macro = new Macro(name);
                foreach(var p in parameters.Split(","))
                    if (!string.IsNullOrEmpty(p)) macro.Parameters.Add(p.Trim());

                codeLine = assembler.GetCodeLine();
                while (codeLine != null) {
                    codeLine.ToDelete = true;

                    if (codeLine.IsDirective) {
                        (directive, macroName) = codeLine.Directive;

                        if (directive.Equals("endm")) break;
                    } 
                    macro.Lines.Add(codeLine);
                    codeLine = assembler.GetCodeLine();
                }

                assembler.Macros.Add(name, macro);

            } }
        };

        private Regex MacroNameRegex = new Regex(@"(?<macroname>\w*)\((?<parameters>.*)\)");

        private List<int> ConvertParameterToListOfNumbers(string parameter) {
            var values = new List<int>();
            foreach (var p in parameter.Split(","))
                values.Add(EvaluateExpression(p));
            return values;
        }

        private int CodeLineIndex = 0;
        private CodeLine? PeekCodeLine() {
            if (CodeLineIndex < CodeLines.Count) return CodeLines[CodeLineIndex];
            return null;
        }
        private CodeLine? GetCodeLine() {
            if (CodeLineIndex < CodeLines.Count) return CodeLines[CodeLineIndex++];
            return null;
        }

        private void OutputCodeLines() {
            foreach (var codeLine in CodeLines)
                DebugLogging($"   {codeLine.SourceFile}.{codeLine.LineNumber} => {codeLine.OriginalLine}");
        }

        public void Assemble(string filename) {
            AddUpdateVariable("ORG", 0);
            AddUpdateVariable("PC", 0);

            DebugLogging($"Phase 0 - Loading");
            IncludeFile(filename);

            OutputCodeLines();

            DebugLogging($"   Loaded {CodeLines.Count} lines.");
            DebugLogging($"Phase 1 - Collection of Variables, Labels and Macros");

            var codeLine = PeekCodeLine();
            while (codeLine != null) {
                if (codeLine.IsAssignment) {
                    var (left, right) = codeLine.Assignment;

                    var value = EvaluateExpression(right);

                    if (left.Equals("*")) {
                        ProgramStart = ProgramCounter = value;
                    } else {
                        AddUpdateVariable(left, value);
                    }
                    GetCodeLine(); // Or CodeLineIndex ++;
                } else if (codeLine.IsDirective) {
                    var (directive, parameter) = codeLine.Directive;

                    if (!DirectiveFunctions.ContainsKey(directive)) {
                        DebugLogging($"Error: Unrcognized directive '{directive}'");
                    } else {
                        DirectiveFunctions[directive](this, parameter);
                    }
                    GetCodeLine(); // Or CodeLineIndex ++;
                } else if (codeLine.IsCommand) {
                    var (command, parameter) = codeLine.Command;

                    if (!CommandFunctions.ContainsKey(command)) {
                        DebugLogging($"Error: Unrcognized commnad '{command}'");
                    } else {
                        CommandFunctions[command](this, parameter);
                    }

                    //var values = new List<int>();
                    //foreach (var p in parameter.Split(",")) {
                    //    var value = EvaluateExpression(p);
                    //    values.Add(value);
                    //}

                    //if (command.Equals("BYTE", StringComparison.InvariantCultureIgnoreCase)) {
                    //    foreach (var byteValue in values)
                    //        PushByteToMemory((byte)byteValue);
                    //}
                    //if (command.Equals("WORD", StringComparison.InvariantCultureIgnoreCase)) {
                    //    foreach (var wordValue in values)
                    //        PushWordToMemory(wordValue);
                    //}
                    GetCodeLine(); // Or CodeLineIndex ++;
                } else {
                    var (label, statement) = codeLine.ParsedCode;

                    if (!string.IsNullOrEmpty(label))
                        AddUpdateVariable(label, ProgramCounter);

                    if (!string.IsNullOrEmpty(statement)) {
                        DebugLogging($"   {statement}");
                    }
                    GetCodeLine(); // Or CodeLineIndex ++;
                }

                codeLine = PeekCodeLine();
            }

            // Now remove the ToDelete codelines
            CodeLines = CodeLines.Where(cl => !cl.ToDelete).ToList();

            OutputCodeLines();



            DebugLogging($"");
            DebugLogging("Macros");
            foreach (var macroName in Macros.Keys) {
                DebugLogging($"   {macroName} ({string.Join(", ", Macros[macroName].Parameters)})");
                foreach (var line in Macros[macroName].Lines)
                    DebugLogging($"   => {line.OriginalLine}");
            }

            DebugLogging($"Phase 2 - Macro Expansion");

            var newCodeLines = new List<CodeLine>();
            foreach (var oldCodeLine in CodeLines) {
                if (MacroRegex.IsMatch(oldCodeLine.OriginalLine)) {
                    var assignmentMatch = MacroRegex.Match(oldCodeLine.OriginalLine);
                    var macroName = assignmentMatch.Groups["macroname"].Value.Trim();
                    var parameters = assignmentMatch.Groups["parameters"].Value.Trim();

                    var parameterValues = new List<string>();
                    foreach (var parameterValue in parameters.Split(","))
                        if (!string.IsNullOrEmpty(parameterValue)) parameterValues.Add(parameterValue.Trim());

                    var macro = Macros[macroName];

                    var pattern = assignmentMatch.Groups[0].Value;
                    oldCodeLine.OriginalLine = oldCodeLine.OriginalLine.Replace(pattern, ReplaceParametersInLine(macro.Lines[0].OriginalLine.Trim(), macro.Parameters, parameterValues));
                    newCodeLines.Add(oldCodeLine);
                    if (macro.Lines.Count > 1) {
                        for (int index = 1; index < macro.Lines.Count; index++) {
                            var newCodeLine = macro.Lines[index];
                            newCodeLine.OriginalLine = ReplaceParametersInLine(newCodeLine.OriginalLine, macro.Parameters, parameterValues);
                            newCodeLine.SourceFile = "MacroExpansion";
                            newCodeLine.LineNumber = 0;
                            newCodeLines.Add(newCodeLine);
                        }
                    }
                } else 
                    newCodeLines.Add(oldCodeLine);
            }
            CodeLines = newCodeLines;

            OutputCodeLines();

            DebugLogging($"");
            DebugLogging("Variables");
            foreach (var variableName in Variables.Keys)
                DebugLogging($"   {variableName} = ${ValueAsHex(GetVariable(variableName))}");

            DebugLogging($"");
            var location = ProgramStart;
            var linePos = 0;
            var hexOutput = string.Empty;
            foreach (var byteValue in Bytes) {
                if (linePos == 0) {
                    hexOutput += $"{location.ToString("X4")} :";
                }
                hexOutput += $" {byteValue.ToString("X2")}";
                linePos += 1;
                location += 1;
                if (linePos == 16) {
                    DebugLogging(hexOutput);
                    hexOutput = string.Empty;
                    linePos = 0;
                }
            }
            DebugLogging(hexOutput);
        }

        private string ReplaceParametersInLine(string line, List<string> parameterNames, List<string> parameterValues) {
            if (parameterNames.Count != parameterValues.Count) {
                throw new Exception($"length of parameterNames != length of parameterValues");
            }

            for (int index = 0; index < parameterNames.Count; index++) {
                line = line.Replace(parameterNames[index], parameterValues[index]);
            }

            return line;
        }

        private Regex MacroRegex = new Regex(@"@(?<macroname>\w*)(?:\((?<parameters>[^\)]*)\))?");

        private string ValueAsHex(int value) {
            if (value > 255) return value.ToString("X2");
            return value.ToString("X4");
        }


        private int EvaluateExpression(string expression) {
            expression = HexRegex.Replace(expression, @"0x${hex}");
            expression = BinaryRegex.Replace(expression, @"0b${binary}");

            var variables = string.Empty;
            foreach (var variableName in Variables.Keys)
                variables += $"var {variableName} = {GetVariable(variableName)};" + Environment.NewLine;

            var toEvaluate = variables + expression;
            var result = CSharpScript.EvaluateAsync<int>(toEvaluate).Result;



            return result;
        }

        private void IncludeFile(string filename) {
            DebugLogging($"   Loading '{filename}'.");
            var lines = File.ReadAllLines(filename);
            var lineNumber = 0;

            foreach (var line in lines) {
                var codeLine = new CodeLine(line, filename, lineNumber);
                lineNumber += 1;

                if (codeLine.IsDirective) {
                    var (directive, parameter) = codeLine.Directive;

                    if (directive.Equals("include"))
                        IncludeFile(parameter);
                    else
                        CodeLines.Add(codeLine);
                } else
                    CodeLines.Add(codeLine);
            }
            DebugLogging($"   Loaded '{filename}' - {lineNumber} lines.");
        }


        public class CodeLine {
            public string OriginalLine { get; set; }

            public string Code { get; set; }
            public string Comment { get; set; }

            public string SourceFile { get; set; }
            public int LineNumber { get; set; }

            public bool ToDelete { get; set; } = false;

            public CodeLine(string line, string sourceFile = "", int lineNumber = 0) {
                OriginalLine = line;
                SourceFile = sourceFile;
                LineNumber = lineNumber;

                var commentMatch = CommentRegex.Match(line);
                Code = commentMatch.Groups["code"].Value;
                Comment = commentMatch.Groups["comment"].Value;
            }

            public bool IsDirective {
                get {
                    return DirectiveRegex.IsMatch(Code);
                }
            }

            public (string, string) Directive {
                get {
                    string directive = string.Empty, parameter = string.Empty;

                    if (DirectiveRegex.IsMatch(Code)) {
                        var directiveMatch = DirectiveRegex.Match(Code);
                        directive = directiveMatch.Groups["directive"].Value.Trim().ToLowerInvariant();
                        parameter = directiveMatch.Groups["parameter"].Value.Trim();
                    }
                    return (directive, parameter);
                }
            }

            public bool IsAssignment {
                get {
                    return AssignmentRegex.IsMatch(Code);
                }
            }
            public (string, string) Assignment {
                get {
                    string left = string.Empty, right = string.Empty;

                    if (AssignmentRegex.IsMatch(Code)) {
                        var assignmentMatch = AssignmentRegex.Match(Code);
                        left = assignmentMatch.Groups["left"].Value.Trim();
                        right = assignmentMatch.Groups["right"].Value.Trim();
                    }
                    return (left, right);
                }
            }

            public bool IsCommand {
                get {
                    return CommandRegex.IsMatch(Code);
                }
            }

            public (string, string) Command {
                get {
                    string command = string.Empty, parameter = string.Empty;

                    if (CommandRegex.IsMatch(Code)) {
                        var commandMatch = CommandRegex.Match(Code);
                        command = commandMatch.Groups["command"].Value.Trim().ToLowerInvariant();
                        parameter = commandMatch.Groups["parameter"].Value.Trim();
                    }
                    return (command, parameter);
                }
            }

            public (string, string) ParsedCode {
                get {
                    string label = string.Empty, statement = string.Empty;

                    if (CodeRegex.IsMatch(Code)) {
                        var codeMatch = CodeRegex.Match(Code);
                        label = codeMatch.Groups["label"].Value.Trim();
                        statement = codeMatch.Groups["statement"].Value.Trim();
                    }

                    return (label, statement);
                }
            }

            private Regex CommentRegex = new Regex(@"^(?<code>.*?)?(?<comment>;.*)?$", RegexOptions.Multiline);
            private Regex AssignmentRegex = new Regex(@"^(?<left>.*)=(?<right>.*)$", RegexOptions.Multiline);
            private Regex CodeRegex = new Regex(@"^(?:(?<label>.*):)?(?<statement>.*)?$", RegexOptions.Multiline);


            private Regex CommandRegex = new Regex(@"\.(?<command>\w*)\s(?<parameter>.*)");
            private Regex DirectiveRegex = new Regex(@"^#(?<directive>\w*)\s*?(?:(?<parameter>.*))??$", RegexOptions.Multiline);

        }
    }
}

// ^\s*(?<opcode>[^\s]{3})\s*(?:(?:\#(?<imm>.*))|(?:\((?<indx>.*),x\))|(?:\((?<indy>.*)\),y)|(?:\((?<ind>.*)\))|(?:(?<indexx>.*),x)|(?:(?<indexy>.*),y)|(?<addr>.*))\s*$
