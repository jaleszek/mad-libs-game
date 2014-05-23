require 'spec_helper'

describe Sentence do
  describe '#extract_fragments' do
    it 'extracts proper fragments' do
      eeftm "Can ((noun)) please ((verb)) go to the ((noun))",
       ["Can ", "((noun))", " please ", "((verb))", " go to the ", "((noun))"]

      eeftm "Go (((( ) and watch (asd) ((ad)) ))(((", 
        ["Go (((( ) and watch (asd) ", "((ad))", " ))((("]

      eeftm "(( (asd) ))", ["(( (asd) ))"]
      eeftm "(( asd ))", ["(( asd ))"]
      eeftm "(( a s))", ["(( a s))"]
      eeftm "((wds))   ((q11))((ww))", ["((wds))", "   ", "((q11))", "((ww))"]
      eeftm("((a:gem))asdasd", ["((a:gem))", "asdasd"])
    end
  end

  describe '#ask' do
    it 'asks for hidden words' do
      sentence = described_class.new("((a:gem)) it's a dic((a))")
      expect(sentence.ask).to eq('a:gem')
      expect(sentence.ask).to eq(nil)

      sentence = described_class.new("((w:gem)) asdad ((w)) ((wwww))")
      expect(sentence.ask).to eq('w:gem')
      expect(sentence.ask).to eq('wwww')
      expect(sentence.ask).to eq(nil)
    end
  end

  describe '#answer' do
    context 'after completion' do
      it 'stores answer per gap' do
        sentence = described_class.new("((a:gem)) its a dic((a))")
        question = sentence.ask
        sentence.answer('dude')

        expect(sentence.to_s).to eq('dude its a dicdude')
      end

      it 'records answers' do
        sentence = described_class.new('((a:gem)) uuu it is a ((a)) and mother((f:bu))')
        question = sentence.ask
        sentence.answer('dude2')
        expect(sentence.to_s).to eq('dude2 uuu it is a dude2 and mother___')
        question = sentence.ask
        sentence.answer('bu')

        expect(sentence.to_s).to eq('dude2 uuu it is a dude2 and motherbu')
      end 
    end
    context 'before completion' do
      it 'replaces gaps with placeholders' do
        sentence = described_class.new("((a:gem)) uu as ((a))")
        expect(sentence.to_s).to eq('___ uu as ___')
      end
    end
  end
end

def expect_extract_fragments_to_match(string_sentence, expected_fragments)
  sentence = described_class.new(string_sentence)
  expect(sentence.extract_fragments).to eq(expected_fragments)
end

alias :eeftm :expect_extract_fragments_to_match
