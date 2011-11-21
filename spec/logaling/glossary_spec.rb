# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), "..", "spec_helper")
require "fileutils"

module Logaling
  describe Glossary do
    let(:project) { "spec" }
    let(:glossary) { Glossary.new(project, 'en', 'ja') }
    let(:glossary_path) { Glossary.build_path(project, 'en', 'ja') }

    before do
      FileUtils.remove_entry_secure(File.join(LOGALING_HOME, 'projects', 'spec'), true)
    end

    describe '#create' do
      context 'when glossary already exists' do
        before do
          FileUtils.mkdir_p(File.dirname(glossary_path))
          FileUtils.touch(glossary_path)
        end

        it {
          -> { glossary.create }.should raise_error(Logaling::CommandFailed)
        }
      end

      context '' do
        # <glossary name>.source-language.target_language.yml というファイル名で用語集が作成されること
        it 'specified glossary should has created' do
          FileUtils.mkdir_p(File.dirname(glossary_path))
          glossary.create
          File.exists?(glossary_path).should be_true
        end
      end
    end

    describe '#add' do
      context 'with arguments show new bilingual pair' do
        before do
          glossary.add("spec", "スペック", "テストスペック")
        end

        it 'glossary yaml should have that bilingual pair' do
          yaml = YAML::load_file(glossary_path)
          term = yaml.index({"source_term"=>"spec", "target_term"=>"スペック", "note"=>"テストスペック"})
          term.should_not be_nil
        end
      end

      context 'with arguments show existing bilingual pair' do
        before do
          glossary.add("user", "ユーザ", "ユーザーではない")
        end

        it {
          -> { glossary.add("user", "ユーザ", "ユーザーではない") }.should raise_error(Logaling::TermError)
        }
      end
    end

    describe '#update' do
      before do
        glossary.add("user", "ユーザ", "ユーザーではない")
      end

      context 'with new-terget-term show existing bilingual pair' do
        it {
          -> { glossary.update("user", "ユーザー", "ユーザ", "やっぱりユーザー") }.should raise_error(Logaling::TermError)
        }
      end

      context 'with source-term arguments show not existing bilingual pair' do
        it {
          -> { glossary.update("use", "ユーザ", "ユーザー", "やっぱりユーザー") }.should raise_error(Logaling::TermError)
        }
      end

      context 'with target-term arguments show not existing bilingual pair' do
        it {
          -> { glossary.update("user", "ユー", "ユーザー", "やっぱりユーザー") }.should raise_error(Logaling::TermError)
        }
      end
    end

    describe '#delete' do
      before do
        glossary.add("user", "ユーザ", "ユーザーではない")
      end

      context 'with arguments show not existing bilingual pair' do
        it {
          -> { glossary.delete("user", "ユーザー") }.should raise_error(Logaling::TermError)
        }
      end
    end

    describe '#lookup' do
      before do
        glossary.add("user", "ユーザ", "ユーザーではない")

        db_home = File.join(LOGALING_HOME, "db")
        glossarydb = Logaling::GlossaryDB.new
        glossarydb.open(db_home, "utf8") do |db|
          db.recreate_table(db_home)
          db.load_glossaries(File.join(LOGALING_HOME, "projects", project, "glossary"))
        end
      end

      context 'with arguments show not existing bilingual pair' do
        it {
          -> { glossary.delete("user", "ユーザー") }.should raise_error(Logaling::TermError)
        }
      end
    end

    after do
      FileUtils.remove_entry_secure(File.join(LOGALING_HOME, 'projects', 'spec'), true)
    end
  end
end
