module Git
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
end

# Use git cat-file -t 34u231io5 and git cat-file -p 23487135y to see object types and contents
