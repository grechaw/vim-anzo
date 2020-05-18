runtime! plugin/vimanzo.vim

describe 'Vimanzo Overview'
  it 'returns something'
    Expect vimanzo#Overview() == "success"
  end
end
