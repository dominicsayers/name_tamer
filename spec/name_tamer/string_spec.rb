# frozen_string_literal: true

describe String do
  it 'has a color' do
    expect('xxx'.yellow).to eq("\e[33mxxx\e[0m")
  end
end
