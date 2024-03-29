require 'spec_helper'

describe ApplicationHelper do
  describe "markdown method" do
    it "should return nil if nil given" do
      markdown(nil).should be_nil
    end

    it "should encode markdown text into html" do
      markdown("hello").should include("<p>hello</p>")
      markdown("- hello").should include("<ul>\n<li>hello</li>\n</ul>")
      sentence = Faker::Lorem.sentence(50)
      markdown(sentence).should include(sentence)
    end

    describe "allowed tags" do
      [:table, :tr, :td,
       :section, :div,
       :span].each do |tag|
        it "should output #{tag} tag as-is" do
          str = "<#{tag}>hoge</#{tag}>"
          markdown(str).should include(str)
        end
      end

      [:br].each do |tag|
        it "should output #{tag} tag as-is" do
          str = "<#{tag} />"
          markdown(str).should include(str)
        end
      end
    end

    describe "non-allowed tags" do
      it "should sanitize script tag" do
        str = "<script></script>"
        markdown(str).should_not include(str)
      end
    end
  end

  describe "add_debug method" do
    it "should add objs to be debug-printed" do
      helper.instance_eval("@debug_objs").should == nil
      helper.add_debug(:hello)
      helper.instance_eval("@debug_objs").should_not == nil
    end
  end
end
