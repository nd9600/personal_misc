# from https://howistart.org/posts/nim/1/index.html

import macros

{.push overflowchecks: off .}
proc xinc(c: var char) = inc c
proc xdec(c: var char) = dec c
{.pop.}


proc compile(code: string): NimNode =
    var stmts = @[newStmtList()]

    template addStmt(text): typed =
        stmts[stmts.high].add(parseStmt(text))

    addStmt("var tape: array[1_000_00, char]")
    addStmt("var tapePos = 0")

    for c in code:
        case c
        of '+': addStmt "xinc tape[tapePos]"
        of '-': addStmt "xdec tape[tapePos]"
        of '>': addStmt "inc tapePos"
        of '<': addStmt "dec tapePos"
        of '.': addStmt "stdout.write tape[tapePos]"
        of ',': addStmt "tape[tapePos] = stdin.readChar"
        of '[': stmts.add(newStmtList())
        of ']':
            var loop = newNimNode(nnkWhileStmt)
            loop.add(parseExpr("tape[tapePos] != '\\0'"))
            loop.add(stmts.pop)
            stmts[stmts.high].add(loop)
        else: discard

    result = stmts[0]

macro compileString*(code: string): typed =
    ## Compiles `code` into Nim code that reads from stdin and writes to stdout
    compile code.strval

macro compileFile*(filename: string): typed =
    ## Compiles the code in `filename` into Nim code that reads from stdin and writes to stdout
    compile staticRead(filename.strval)


proc mandelbrot = compileFile("mandelbrot.b")
mandelbrot()