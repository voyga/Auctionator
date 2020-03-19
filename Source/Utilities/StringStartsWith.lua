function Auctionator.Utilities.StringStartsWith(testString, comparator)
  if testString == nil or starterString == nil then
    return false
  end

  return string.sub(
    testString,
    1,
    math.min(string.len(testString), string.len(comparator))
  ) == comparator
end
