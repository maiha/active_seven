class Array
  def optionize(*args)
    NamedOptions.new(self, *args)
  end
end
