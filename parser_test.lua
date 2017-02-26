local test = require 'unittest'
local parser = require 'parser'
local Token = require 'token'

-- Because laziness
local p = parser

test.addTest(function()
  -- Test result toString
  local r = parser.Result("value", 2)
  test.assertEqual(tostring(r), "Result(value, 2)")
end)

test.addTest(function()
  -- Test result equality
  local r1 = parser.Result("value", 2)
  local r2 = parser.Result("value", 2)
  test.assertEqual(r1, r2)
end)

test.addTest("Reserved construction", function()
  local r = parser.Reserved(1, "tag")
  test.assertEqual(r.value, 1)
  test.assertEqual(r.tag, "tag")
end)

test.addTest("Reserved apply", function()
  local r = parser.Reserved(2, "tag2")
  local tokens = {Token(2, "tag2")}
  local result = r(tokens, 1)
  test.assertEqual(result, parser.Result(2, 2))
end)

test.addTest("Reserved no match", function()
  local r = parser.Reserved(3, "tag3")
  local tokens = {Token(2, "tag2")}
  local result = r(tokens, 1)
  test.assertEqual(result, nil)
  test.assertEqual(r({}, 1), nil)
end)

test.addTest("Tag apply", function()
  local tag = parser.Tag("tag1")
  local tokens = {nil, nil, Token(1, "tag1")}
  test.assertEqual(tag(tokens, 3), parser.Result(1, 4))
end)

test.addTest("Concat apply", function()
  local tag1 = parser.Tag("first")
  local tag2 = parser.Tag("second")
  local concat = parser.Concat(tag1, tag2)
  local tokens = {Token(10, "first"), Token(11, "second")}
  local r = concat(tokens, 1)
  test.assertEqual(r, parser.Result({10, 11}, 3))
end)

test.addTest("Alternate left only", function()
  local alt = parser.Alternate(parser.Tag("simple"), parser.Tag("no"))
  test.assertEqual(
    alt({Token("value", "simple")}, 1), 
    parser.Result("value", 2)
  )
end)

test.addTest("Alternate right only", function()
  local alt = parser.Alternate(parser.Tag("no"), parser.Tag("simple"))
  test.assertEqual(
    alt({Token("value2", "simple")}, 1), 
    parser.Result("value2", 2)
  )
end)

test.addTest("Opt correct parse", function()
  local opt = parser.Opt(parser.Tag("simple"))
  test.assertEqual(
    opt({Token("optical", "simple")}, 1), 
    parser.Result("optical", 2)
  )
end)

test.addTest("Opt no parse", function()
  local opt = parser.Opt(parser.Tag("no"))
  test.assertEqual(
    opt({Token("noway", "nuh")}, 1), 
    parser.Result(nil, 1)
  )
end)

test.addTest("Rep correct parse", function()
  local rep = parser.Rep(parser.Tag("simple"))
  test.assertEqual(
    rep({Token(1, "simple"), Token(2, "simple")}, 1), 
    parser.Result({1, 2}, 3)
  )
end)

test.addTest("Process apply", function()
  local process = p.Process(p.Tag("simple"), function(value)
    return value * 2 + 1
  end)
  test.assertEqual(
    process({Token(10, "simple")}, 1),
    p.Result(21, 2)
  )
end)

test.runTests()
