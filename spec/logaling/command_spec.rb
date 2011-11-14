# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe Logaling::Command do
  let(:command) { Logaling::Command.new([], {
    "glossary"=>"spec",
    "source-language"=>"en",
    "target-language"=>"ja",
    "source-term"=>"spec",
    "target-term"=>"テスト",
    "new-target-term"=>"スペック",
    "note"=>"備考"})}
  let(:glossary_path) { File.join(LOGALING_HOME, "/spec.en.ja.yml") }

  before do
    FileUtils.remove_file(glossary_path, true)
  end

  describe '#create' do
    context 'with arguments show non-existent glossary' do

      before do
        command.create
      end

      it "glossary yaml should be newly created" do
        File.exists?(glossary_path).should be_true
      end
    end
  end

  describe "#update" do
    context "not given source-term option" do
      # should show err
    end

    context "not given target-term option" do
      #should show err
    end

    context "not given new-target-term option" do
      #should show err
    end

    context "not given note option" do
      before do
        FileUtils.remove_file(glossary_path, true)
        command.create
        command.add
        command.update
      end

      subject { YAML::load_file(glossary_path) }

      it "glossary yaml should be updated" do
        should == [{"source-term"=>"spec", "target-term"=>"スペック", "note"=>"備考"}]
      end
    end
  end
  after do
    FileUtils.remove_file(glossary_path, true)
  end
end
