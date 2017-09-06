require 'test_helper'

class DecorationTest < MiniTest::Spec
  class SongCell < Cell::ViewModel
    include Decoration

    def show
      "#{model.title}#{model.number}"
    end

  end

  class SpecialDecorator < Cell::ViewModel::Decoration::EscapeDecorator
    def title
      super + escape!('<br> escape on your own')
    end
  end

  class FancySongCell < SongCell
    self.decorator_class = SpecialDecorator
  end

  let (:song) { Struct.new(:title, :number).new("<b>Please escape!</b>", 42) }
  let (:artist) { Struct.new(:name, :song).new("<b>Your mom</b>", song) }

  # model properties should be escaped automatically if string
  it { SongCell.(song).().must_equal "&lt;b&gt;Please escape!&lt;/b&gt;42" }

  it { FancySongCell.(song).().must_equal "&lt;b&gt;Please escape!&lt;/b&gt;&lt;br&gt; escape on your own42" }

  # decorate objects, too
  class ArtistCell < Cell::ViewModel
    include Decoration

    def show
      "#{model.song.title} - #{model.name}"
    end
  end

  it { ArtistCell.(artist).().must_equal "&lt;b&gt;Please escape!&lt;/b&gt; - &lt;b&gt;Your mom&lt;/b&gt;" }

  let (:decorator) { Cell::ViewModel::Decoration::EscapeDecorator.new(song) }
  it { (decorator.title + decorator.title).to_s.must_equal "&lt;b&gt;Please escape!&lt;/b&gt;&lt;b&gt;Please escape!&lt;/b&gt;" }
end
