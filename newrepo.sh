#!/bin/sh
# git-create-branch <branch_name>
# Thanks: http://www.zorched.net/2008/04/14/start-a-new-branch-on-your-remote-git-repository/
if [ $# -ne 1 ]; then
          echo 1>&2 Usage: $0 branch_name
          exit 127
fi

set branch_name = $1
git push origin origin:refs/heads/${branch_name}
git fetch origin
git checkout --track -b ${branch_name} origin/${branch_name}
git pull
## new version
# git checkout -b ${branch_name}
# git push origin ${branch_name}
# git branch --set-upstream ${branch_name} origin/${branch_name}
