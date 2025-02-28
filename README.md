M script interpreter implemented in the V programming language. Allows for basic scripting operations, including variable manipulation, file system interactions, arithmetic calculations, conditional logic, and script definitions. The interpreter is designed to be lightweight and extensible, providing a foundation for automating tasks and creating simple command-line tools.

## Features

  * **Variable Assignment:**
      * String variables: Assign string values to named variables.
      * Numeric variables: Assign numerical values to named variables, supporting basic arithmetic operations.
  * **File System Operations:**
      * **Write File (`i`):** Create or overwrite files with specified content.
      * **Append to File (`+i`):** Add content to the end of an existing file.
      * **Move/Rename File (`m`):** Rename or move files.
      * **Read File to Variable (`o`):** Read the content of a file into a string variable.
  * **Output to Console (`>`):** Print strings or variable values to the standard output.
  * **Arithmetic Operations:**
      * **Addition (`+`):** Add two numbers (either numeric variables or literals).
      * **Subtraction (`-`):** Subtract two numbers.
      * **Multiplication (`*`):** Multiply two numbers.
      * **Division (`/`):** Divide two numbers.
      * **Exponentiation (`**`):** Raise a number to the power of another.
      * **Store Result (`#`):** Store the result of the last arithmetic operation (stored in a temporary `=` variable) into a named numeric variable.
  * **Script Definition and Execution (`~` and `.`):**
      * Define reusable scripts (macros) using the `~` operator, storing them under a given name.
      * Execute defined scripts using the `.` operator.
  * **Conditional Logic (`%`, `=`, `!=`, `;`, `?`, `!`):**
      * **Toggle `otherwise` Flag (`%`):** Invert the boolean `otherwise` flag.
      * **Equality Check (`=`):** Set the `otherwise` flag based on the equality of two values.
      * **Inequality Check (`!=`):** Set the `otherwise` flag based on the inequality of two values.
      * **Conditional AND (`;`):** Perform a logical AND with the current `otherwise` flag.
      * **Conditional Execution - If True (`?`):** Execute a script block only if the `otherwise` flag is true.
      * **Conditional Execution - If False (`!`):** Execute a script block only if the `otherwise` flag is false.
  * **Looping (Repetition) (`r`):**
      * Repeat a script a specified number of times.
  * **Shell Command Execution (`<`):**
      * Execute shell commands and capture the standard output into the `r` state variable.
  * **Quoting (`'...'`):**
      * Use single quotes to treat enclosed text as a single string argument, useful for including spaces and special characters.
  * **Variable Substitution (`~variable_name`):**
      * Embed the value of string or numeric variables directly into commands and strings using the `~` prefix.

## Getting Started

### Prerequisites

  * **V Programming Language:** Ensure you have the V programming language installed on your system. You can find installation instructions at [https://vlang.io/](https://www.google.com/url?sa=E&source=gmail&q=https://vlang.io/).

### Compilation and Execution

1.  **Clone the repository (if applicable) or save the code:** Save the provided V code (both `main.m` and the script code) into files, for example, `interpreter.v` and `my_script.m`.

2.  **Compile the interpreter:** Open a terminal in the directory where you saved `interpreter.v` and compile it using the V compiler:

    ```bash
    v -prod m.v
    ```

    This will create an executable file named `m` (or `m.exe` on Windows).

3.  **Run the interpreter with a script:** Execute the interpreter, providing the path to your script file (`my_script.m` or similar) using the `-src` flag:

    ```bash
    ./m -src my_script.m
    ```

    If you omit the `-src` flag, it defaults to looking for a script named `main.m` in the current directory.

### Studying the Implementation

The core logic of the interpreter is contained within the `SR` struct and its associated methods in the `interpreter.v` file.

  * **`SR` Struct:**  Represents the interpreter's state, holding variables, scripts, operations, and parsing buffers.
  * **`munch(src string)`:** The main function responsible for processing the input script string, character by character.
  * **`interpret(t u8)`:** Handles the interpretation of individual characters, managing quoting, variable substitution, and command parsing.
  * **`chwok()`:** Processes a "word" (separated by spaces or newlines) to identify operations, arguments, or variable declarations.
  * **`routine(moniker string, f FN, bounds u8)`:**  Registers built-in operations (like `i`, `+`, `>`, etc.) with the interpreter, defining their function (`f`) and expected number of arguments (`bounds`).

The `main.v` file's `main()` function sets up the interpreter, defines all the standard operations, and then loads and executes the script specified by the `-src` command-line argument.  Reviewing the `main()` function and the `routine` calls is crucial to understanding the available commands and their syntax.

## Language Syntax and Operations

The script language is word-based and uses a combination of keywords, operators, and variable names.

### Basic Syntax Elements

  * **Words:** Separated by spaces or newlines. Words can be operations, arguments, variable names, or string literals.
  * **Operations/Keywords:**  Predefined commands like `i`, `+i`, `m`, `o`, `>`, `n`, `+`, `-`, `*`, `/`, `**`, `#`, `~`, `.`, `%`, `=`, `!=`, `;`, `?`, `!`, `r`, `<`.
  * **String Literals:** Enclosed in single quotes `` `...` ``.  Use `^` to escape a single quote within a quoted string ( `^` becomes `` ` `` inside quotes).
  * **Numeric Literals:** Numbers (integers and floating-point) without any special delimiters.
  * **String Variables:** Declared implicitly by assigning a string value. Referenced using `~variable_name` for substitution.
  * **Numeric Variables:** Declared using `#variable_name` followed by a numeric value on the preceding line. Also referenced using `~variable_name` for substitution.
  * **Comments:**  There are no explicit comment markers. Text that doesn't conform to operations or variable declarations will be treated as arguments or potentially ignored depending on context.

### Operations and their Syntax

Here's a breakdown of each operation and its syntax:

| Operation     | Syntax                                   | Description                                                                 |
|---------------|--------------------------------------------|-----------------------------------------------------------------------------|
| **Write File**  | `i <filename> <content>`                  | Writes `<content>` to `<filename>`, overwriting if the file exists.         |
| **Append File** | `+i <filename> <content>`                 | Appends `<content>` to the end of `<filename>`.                             |
| **Move File**   | `m <source_filename> <destination_filename>` | Moves or renames `<source_filename>` to `<destination_filename>`.       |
| **Read File**   | `o <filename> <variable_name>`            | Reads the content of `<filename>` into the string `<variable_name>`.      |
| **Print**       | `> <message>`                             | Prints `<message>` to the console.                                        |
| **Number Var**  | `<value> #<variable_name>`                | Declares a numeric variable `<variable_name>` with value `<value>`.         |
| **Addition**    | `+ <operand1> <operand2>`                 | Adds `<operand1>` and `<operand2>`, result in `=` temporary variable.        |
| **Subtraction** | `- <operand1> <operand2>`                 | Subtracts `<operand2>` from `<operand1>`, result in `=` temporary variable. |
| **Multiplication**| `* <operand1> <operand2>`                 | Multiplies `<operand1>` and `<operand2>`, result in `=` temporary variable.   |
| **Division**    | `/ <operand1> <operand2>`                 | Divides `<operand1>` by `<operand2>`, result in `=` temporary variable.      |
| **Exponent**    | `** <base> <exponent>`                   | Raises `<base>` to the power of `<exponent>`, result in `=` temporary variable.|
| **Store Result**| `# <variable_name>`                        | Stores the value of the `=` temporary variable into `<variable_name>`.      |
| **Define Script**| `~ <script_name> <script_content>`        | Defines a script named `<script_name>` with the content `<script_content>`. Use `__` for backtick `` ` `` and `##` for underscore `_` in script content definition.|
| **Run Script**  | `. <script_name>`                         | Executes the script named `<script_name>`.                                 |
| **Toggle %**    | `%`                                        | Toggles the `otherwise` flag.                                            |
| **Equals**      | `= <value1> <value2>`                      | Sets `otherwise` flag if `<value1>` is equal to `<value2>`.                |
| **Not Equals**  | `!= <value1> <value2>`                     | Sets `otherwise` flag if `<value1>` is not equal to `<value2>`.             |
| **Conditional AND**| `; <value1> <value2>`                     | Performs conditional AND with `otherwise` flag.                            |
| **If True**     | `? <script_block>`                        | Executes `<script_block>` only if `otherwise` is true.                    |
| **If False**    | `! <script_block>`                        | Executes `<script_block>` only if `otherwise` is false.                   |
| **Repeat**      | `r <repetitions> <script_name>`          | Repeats execution of `<script_name>` `<repetitions>` times.               |
| **Shell Exec**  | `< <command>`                             | Executes `<command>` in the shell, output in `r` state variable.             |

**Note on Variable Substitution:** Variable substitution using `~variable_name` works within quoted strings and as arguments to operations.

## Examples

The `main.m` file provides a good example script demonstrating various features:

```m
50.5 #a
50.5 #b
+ a b
# c

> `~a + ~b = ~c`

2.10 #a
10.2 #b
 a b
# c

> `~a ** ~b = ~c`

> `okay`

`yes` moo
`flowrs can be eaten and are sometimes tasty` yum
> `there is moo? ~moo`

`hoaw wurl and uuuuu ~moo, also ~yum` s
`yep` msg

`> ^~s^
^yep^ moo` rep


~ hi `~rep`

r 2 hi

> `there is moo? ~moo`

`rainbow` gravity

< `echo hi`
> `~r`
```

**Explanation of `main.m` Example:**

1.  **Numeric Variable Declarations and Addition:**

      * `50.5 #a` and `50.5 #b`: Declare numeric variables `a` and `b` with the value 50.5.
      * `+ a b`: Adds `a` and `b`, storing the result in the `=` temporary variable.
      * `# c`: Stores the value from `=` into numeric variable `c`.
      * `> '~a + ~b = ~c'`: Prints a string showing the calculation and substituted variable values.

2.  **Numeric Variable Declarations and Exponentiation:**

      * Similar to step 1, but performs exponentiation (`**`) instead of addition.

3.  **String Variable Declarations and Output:**

      * `` `yes` moo `` and `` `flowrs can be eaten and are sometimes tasty` yum ``: Declare string variables `moo` and `yum` with the given string values.
      * `> 'there is moo? ~moo'`: Prints a string, substituting the value of the `moo` variable.

4.  **String Variable Concatenation and Output:**

      * `` `hoaw wurl and uuuuu ~moo, also ~yum` s ``: Declares string variable `s` with a string that includes substitutions for `moo` and `yum`.
      * `` `yep` msg ``: Declares string variable `msg`.
      * `` `> ^~s^ ^yep^ moo` rep ``: Declares string variable `rep` holding a string with variable substitutions, using `^` to escape backticks within the quoted string for later correct interpretation.

5.  **Script Definition and Repetition:**

      * `~ hi 'rep'`: Defines a script named `hi` with the content of the `rep` variable (which contains the formatted string from the previous step).
      * `r 2 hi`: Repeats the execution of the `hi` script 2 times. This will print the string defined in `rep` twice.

6.  **Shell Command Execution:**

      * `` `rainbow` gravity ``: Declares string variable `gravity`. (Unused in this example, likely for demonstration).
      * `< 'echo hi'`: Executes the shell command `echo hi` and stores the output in the `r` state variable.
      * `> '~r'`: Prints the content of the `r` state variable, which will be the output of the `echo hi` command (i.e., "hi" followed by a newline).

## Limitations and Future Enhancements

  * **Basic Error Handling:** Error handling is minimal. Invalid operations or incorrect syntax may lead to program crashes or unexpected behavior.
  * **Limited Data Types:**  Primarily supports string and numeric data types. Lists or more complex data structures are not natively supported.
  * **Simple Control Flow:** Control flow is limited to conditional execution and basic looping. More advanced control structures (like `for` loops or `while` loops) are not implemented.
  * **No User-Defined Functions (beyond scripts):** Users can define scripts (macros), but not functions with more complex parameter handling or return values.
  * **Security Considerations:** Executing arbitrary shell commands (`<`) can introduce security risks if the script interpreter is used with untrusted input.

**Potential Future Enhancements:**

  * **Improved Error Handling:** Implement more robust error reporting and handling.
  * **Expanded Data Types:** Add support for lists, dictionaries, or other data structures.
  * **More Control Flow Structures:** Implement `for`, `while`, or `if-else` control flow statements.
  * **User-Defined Functions:** Allow users to define functions with parameters and return values for better code organization and reusability.
  * **String Manipulation Functions:** Add built-in functions for common string operations (substring, split, join, etc.).
  * **Input from User:** Implement a mechanism for taking input from the user during script execution.

## Author

Saul van der walt 
saulvdw@kurshok.space

Feel free to contribute to this project or suggest improvements\!

## License

Copyleft GNU3
