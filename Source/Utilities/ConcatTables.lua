function Auctionator.Utilities.ConcatArrays(accumulator, array1, ...)
  if array1 == nil then
    return accumulator
  end

  for index, item in ipairs(array1) do
    accumulator[#accumulator + 1] = array1[index]
  end
  
  return Auctionator.Utilities.ConcatTables(accumulator, ...)
end
