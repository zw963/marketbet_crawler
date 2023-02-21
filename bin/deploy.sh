#!/usr/bin/env bash

function set_backup_policy () {
    set -eu

    backup_path=$1

    # 处理用户输入 7 或 07(有个 0 前缀) 的问题。
    max_backup_count=$((${2}-0))

    oldest_backup_dir="${backup_path}".$max_backup_count
    [[ $max_backup_count -lt 10 ]] && oldest_backup_dir="${backup_path}".0$max_backup_count
    newest_backup_dir="${backup_path}"

    # 如果无编号的 backup 目录不存在, 则直接创建它, 并返回.(即: 无需后续的轮回策略.)
    if [ ! -d "$newest_backup_dir" ]; then
        mkdir -p "$newest_backup_dir"
        return 0
    fi

    # 如果已经达到最大备份, 删除最老的备份.
    if [ -d "$oldest_backup_dir" ]; then
        echo "Deleting oldest backup dir $oldest_backup_dir ..."
        rm -rf "$oldest_backup_dir"
        echo "Done."
    fi

    for i in $(seq -s' ' $max_backup_count -1 0); do
        if [ "$i" -lt 9 ]; then
            [ -d "${backup_path}".0$i ] && mv "${backup_path}".0$i "${backup_path}".0$((i+1))
        elif [ "$i" -eq 9 ]; then
            [ -d "${backup_path}".09 ] && mv "${backup_path}".09 "${backup_path}".10
        else
            [ -d "${backup_path}".$i ] && mv "${backup_path}".$i "${backup_path}".$((i+1))
        fi
    done

    mv "${newest_backup_dir}" "${backup_path}".01

    return 0
}

current=$(cd "$(dirname "$BASH_SOURCE")/.." && pwd)
root=$(cd $current/../.. && pwd)

echo "-----> Fetching new git commits"
(cd $root/scm && git fetch git@github.com:zw963/marketbet_crawler master:master --force) &&
    echo "-----> Using git branch master" &&
    cd $root &&
    set_backup_policy $current 7 &&
    git clone scm $current --recursive --branch master &&
    cd $current &&
    git rev-parse HEAD > .git_revision &&
    git --no-pager log --format="%aN (%h):%n> %s" -n 1 &&
    ln -sfv $root/shared/.rvmrc . &&
    ln -sfv $root/shared/Procfile . &&
    ln -sfv $root/shared/Procfile.local . &&
    ln -sfv $root/shared/log . &&
    ln -sfv $root/shared/tmp . &&
    ln -sfv $root/shared/pids . &&
    ln -sfv $root/shared/public/assets public/assets &&
    ln -sfv $root/shared/db/files db/files &&
    cd . &&
    bundle config set deployment true &&
    bundle config set path $root/shared/bundle &&
    bundle config set without 'development test' &&
    procodile restart && procodile status
