macro for(init, condition, increment, &block)
  {{init}}

  while {{condition}}
    {{block.body}}
    {{increment}}
  end
end
