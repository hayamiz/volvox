require 'spec_helper'

describe ApplicationHelper do
  describe "markdown method" do
    it "should encode markdown text into html" do
      markdown("hello").should include("<p>hello</p>")
      markdown("- hello").should include("<ul>\n<li>hello</li>\n</ul>")
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
end
