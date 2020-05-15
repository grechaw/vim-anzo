
describe 'vimanzo#graph#getGraph'
  it 'a valid graph call'
    Expect vimanzo#graph#getGraph("http://openanzo.org/datasets#NamedGraphs") == 0
  end

  it 'not a graph diplays message'
    Expect vimanzo#graph#getGraph("http://notagraph") == 0
  end
end
