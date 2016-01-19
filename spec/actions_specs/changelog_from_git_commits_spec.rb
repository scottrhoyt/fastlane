describe Fastlane do
  describe Fastlane::FastFile do
    describe "changelog_from_git_commits" do
      it "Collects messages from the last tag to HEAD by default" do
        result = Fastlane::FastFile.new.parse("lane :test do
          changelog_from_git_commits
        end").runner.execute(:test)

        expect(result).to eq("git log --pretty=\"%B\" git\\ describe\\ --tags\\ \\`git\\ rev-list\\ --tags\\ --max-count\\=1\\`...HEAD")
      end

      it "Uses the provided pretty format to collect log messages" do
        result = Fastlane::FastFile.new.parse("lane :test do
          changelog_from_git_commits(pretty: '%s%n%b')
        end").runner.execute(:test)

        expect(result).to eq("git log --pretty=\"%s%n%b\" git\\ describe\\ --tags\\ \\`git\\ rev-list\\ --tags\\ --max-count\\=1\\`...HEAD")
      end

      it "Does not match lightweight tags when searching for the last one if so requested" do
        result = Fastlane::FastFile.new.parse("lane :test do
          changelog_from_git_commits(match_lightweight_tag: false)
        end").runner.execute(:test)

        expect(result).to eq("git log --pretty=\"%B\" git\\ describe\\ \\`git\\ rev-list\\ --tags\\ --max-count\\=1\\`...HEAD")
      end

      it "Collects logs in the specified revision range if specified" do
        result = Fastlane::FastFile.new.parse("lane :test do
          changelog_from_git_commits(between: ['abcd', '1234'])
        end").runner.execute(:test)

        expect(result).to eq("git log --pretty=\"%B\" abcd...1234")
      end

      it "handles tag names with characters that need shell escaping" do
        result = Fastlane::FastFile.new.parse("lane :test do
          changelog_from_git_commits(between: ['v1.8.0(30)', 'HEAD'])
        end").runner.execute(:test)

        expect(result).to eq("git log --pretty=\"%B\" v1.8.0\\(30\\)...HEAD")
      end

      it "Does not accept a string value for between" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            changelog_from_git_commits(between: 'abcd...1234')
          end").runner.execute(:test)
        end.to raise_error(":between must be of type array".red)
      end

      it "Does not accept a :between array of size 1" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            changelog_from_git_commits(between: ['abcd'])
          end").runner.execute(:test)
        end.to raise_error(":between must be an array of size 2".red)
      end

      it "Does not accept a :between array with nil values" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            changelog_from_git_commits(between: ['abcd', nil])
          end").runner.execute(:test)
        end.to raise_error(":between must not contain nil values".red)
      end

      it "Does not include merge commits in the list of commits" do
        result = Fastlane::FastFile.new.parse("lane :test do
          changelog_from_git_commits(include_merges: false)
        end").runner.execute(:test)

        expect(result).to eq("git log --pretty=\"%B\" git\\ describe\\ --tags\\ \\`git\\ rev-list\\ --tags\\ --max-count\\=1\\`...HEAD --no-merges")
      end
    end
  end
end
