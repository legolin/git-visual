=== Description

* git-visual, a browser-based visualized git toolbox using merb and the ruby-git rubygem

=== Usage

Install the app:
  git clone git://github.com/dcparker/git-visual.git
  cd git-visual/script
  cp git-visual /usr/local/bin
Make sure /usr/local/bin is in your $PATH:
  * to view the path:
    echo $PATH
  * to add to the path:
    export PATH="/usr/local/bin:$PATH"
  * to make sure this remains in the path:
    echo "" >> ~/.profile
    echo "export PATH=\"/usr/local/bin:$PATH\"" >> ~/.profile
Navigate to your nearest git repository and type the command
  git-visual
