module Git
  class Lib
    def ls_files
      hsh = {}
      command_lines('ls-files', '--stage').each do |line|
        (info, file) = line.split("\t")
        (mode, sha, stage) = info.split
        hsh[file] = {:path => file, :mode_index => mode, :sha_index => sha}
      end
      hsh
    end

    def diff_full(obj1='HEAD', obj2=:working, opts={})
      opts[:mode] = '-p'
      diff(obj1, obj2, opts)
    end

    def diff_stats(obj1='HEAD', obj2=:working, opts={})
      opts[:mode] = '--numstat'

      hsh = {:total => {:insertions => 0, :deletions => 0, :lines => 0, :files => 0}, :files => {}}

      diff(obj1, obj2, opts).each_line do |file|
        (insertions, deletions, filename) = file.split("\t")
        hsh[:total][:insertions] += insertions.to_i
        hsh[:total][:deletions] += deletions.to_i
        hsh[:total][:lines] = (hsh[:total][:deletions] + hsh[:total][:insertions])
        hsh[:total][:files] += 1
        hsh[:files][filename] = {:insertions => insertions.to_i, :deletions => deletions.to_i}
      end
            
      hsh
    end

    def diff(obj1='HEAD', obj2=:working, opts={})
      diff_opts = [opts[:mode]]

      if obj1 == :index # Compares the staging area with the working copy
      elsif obj2 == :index # Compares some treeish with the staging area
        diff_opts << '--cached'
        diff_opts << obj1
      elsif obj2 == :working # Compares some treeish with the working copy
        diff_opts << obj1
      else # Compares two treeish
        diff_opts << obj1
        diff_opts << obj2 if obj2.is_a?(String)
      end
      diff_opts << ('-- ' + opts[:path_limiter]) if opts[:path_limiter].is_a? String
      command('diff', diff_opts)
    end

    # compares the index and the repository
    def diff_index(treeish)
      hsh = {}
      staged = treeish.is_a?(Array) && treeish.include?('--cached') ? true : false
      command_lines('diff-index', treeish).each do |line|
        (info, file) = line.split("\t")
        (mode_src, mode_dest, sha_src, sha_dest, type) = info.split
        hsh[file] = {:path => file, :mode_repo => mode_src.to_s[1, 7], :mode_index => mode_dest, 
                      :sha_repo => sha_src, :sha_index => sha_dest, :type => type}
        hsh[file][:staged] = true if staged # Add :staged => true if we were only looking at staged files in the first place.
      end
      hsh
    end
  end

  class Log
    def [](i)
      check_log
      @commits[] rescue nil
    end

    def reverse
      check_log
      @commits.reverse rescue nil
    end
  end

  class Object
    class Commit
      def label
        "Commit #{short_objectish}: #{message}"
      end

      def short_objectish
        objectish[0..8]
      end

      def merge?
        parents.length > 1
      end

      def ==(object)
        objectish == object.objectish
      end

      def diff_parent
        Git::Diff.new(@base, self.parent, self)
      end
    end
  end

  class Diff
    SPECIALS = ['index', 'working']
    
    def initialize(base, from=nil, to=nil, path=nil)
      @base = base
      @from = SPECIALS.include?(from) ? from.to_sym : from.to_s
      @to = SPECIALS.include?(to) ? to.to_sym : to.to_s
      @path = path
    end
  end

  class Status

    # class << self
    #   def staged
    #     # Run git diff-index --cached HEAD
    #   end
    # 
    #   def staged_diff
    #     # Run git diff-index --cached -p HEAD
    #   end
    # 
    #   def unstaged
    #     # Run git diff-files
    #   end
    # 
    #   def unstaged_diff
    #     # Run git diff-files -p
    #   end
    # end

    def initialize(base, files=nil)
      @base = base
      @files = files || construct_status
    end

    def staged
      self.class.new(@base, @files.select {|k, f| f.staged})
    end

    def unstaged
      self.class.new(@base, @files.select {|k, f| !f.staged})
    end

    class StatusFile
      remove_method :stage
      remove_method :stage=

      attr_accessor :staged

      def initialize(base, hash)
        @base = base
        @path = hash[:path]
        @type = hash[:type]
        @staged = hash[:staged]
        @mode_index = hash[:mode_index]
        @mode_repo = hash[:mode_repo]
        @sha_index = hash[:sha_index]
        @sha_repo = hash[:sha_repo]
        @untracked = hash[:untracked]
      end
    end

    private
    
      def construct_status
        files = @base.lib.ls_files

        # find untracked in working dir
        Dir.chdir(@base.dir.path) do
          Dir.glob('**/*') do |file|
            if !files[file]
              files[file] = {:path => file, :untracked => true} if !File.directory?(file)
            end
          end
        end

        # find added but not committed - new files
        @base.lib.diff_index('HEAD').each do |path, data|
          files[path] ? files[path].merge!(data) : files[path] = data
          files[path][:staged] = true
        end

        # find modified in tree
        @base.lib.diff_files.each do |path, data|
          files[path] ? files[path].merge!(data) : files[path] = data
          files[path][:staged] = false
        end

        files.each do |k, file_hash|
          files[k] = StatusFile.new(@base, file_hash)
        end

        files
      end
  end
end

# Use git cat-file -t 34u231io5 and git cat-file -p 23487135y to see object types and contents
