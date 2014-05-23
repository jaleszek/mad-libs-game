# I'm so ugly ...
class Sentence
  FRAGMENTS_REGEX = /\(\(\s*(\w|\w:\w)+\s*\)\)/
  attr_reader :string_sentence

  def initialize(string_sentence)
    @string_sentence = string_sentence
    @questions  = {}

  end

  def extract_fragments
    positions = string_sentence.enum_for(:scan, FRAGMENTS_REGEX).map do
      [Regexp.last_match.begin(0), Regexp.last_match.begin(0) + Regexp.last_match.to_s.size]
    end

    last_start = 0

    ranges = []

    positions.each do |start, finish|
      if start != last_start
        ranges << [last_start, start - 1]
        ranges << [start, finish-1]
        last_start = finish
      else
        ranges << [last_start, finish-1]
        last_start = finish
      end
    end

    fragments = ranges.map do |start, finish|
      string_sentence[start..finish]
    end

    unless ranges.empty?
      last_fragment = string_sentence[(ranges.last[1] + 1)..string_sentence.size - 1]
      fragments << last_fragment if last_fragment != ''
    else
      fragments = [string_sentence]
    end
    fragments

  end

  def to_s
    return string_sentence.gsub(FRAGMENTS_REGEX, '___') if @questions.empty?
    res = ""
    extract_fragments.each do |fragment|
      if fragment[0...2] == '(('
        ans_key = fragment[2...-2].split(':')[0]
        answer = @questions[ans_key]
        if answer
          res << answer
        else
          res << '___'
        end

      else
        res << fragment
      end
    end

    res
  end

  def answer(ans)
    @questions[@current_question] = ans
  end

  def ask
    begin
      quest = fragments.next
      @current_question =  quest.split(':')[0]
      @questions[@current_question] = nil
      quest
    rescue StopIteration
      nil
    end
  end

  private

  def fragments
    @fragments ||= enum_for(:iterate)
  end

  def extract_empty_fragments
    p extract_fragments
    extract_fragments.select{|fragment| fragment[0...2] == '(('}
  end

  def iterate
    response = {}
    extract_empty_fragments.each do |fragment|
      key = fragment[2...-2].split(':')[0]
      unless response[key]
        response[key] = true
        yield fragment[2...-2]
      end
    end
  end
end