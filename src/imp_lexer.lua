local lexer = require("lexer")

local module = {
  RESERVED = "RESERVED",
  INT = "INT",
  ID = "ID"
}

local tokenExpressions = {
  {"[ \n\t]+"},
  {"#[^\n]*"},
  -- Wonderful reserved list
  {":=", module.RESERVED},
  {"%{", module.RESERVED},
  {"%}", module.RESERVED},
  {";", module.RESERVED},
  {"%+", module.RESERVED},
  {"%-", module.RESERVED},
  {"%*", module.RESERVED},
  {"/", module.RESERVED},
  {"<=", module.RESERVED},
  {"<", module.RESERVED},
  {">=", module.RESERVED},
  {">", module.RESERVED},
  {"=", module.RESERVED},
  {"!=", module.RESERVED},
  {"and", module.RESERVED},
  {"or", module.RESERVED},
  {"not", module.RESERVED},
  {"if", module.RESERVED},
  {"then", module.RESERVED},
  {"else", module.RESERVED},
  {"while", module.RESERVED},
  {"do", module.RESERVED},
  {"end", module.RESERVED},
  -- 
  {"[0-9]+", module.INT},
  {"[A-Za-z][A-Za-z0-9_]*", module.ID}
}

function module.lex(characters)
  return lexer.lex(characters, tokenExpressions)
end

return module
