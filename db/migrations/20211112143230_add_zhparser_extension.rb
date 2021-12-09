Sequel.migration do
  up do
    run 'CREATE EXTENSION zhparser;'
    run "DROP TEXT SEARCH CONFIGURATION IF EXISTS zhparser;"
    run "CREATE TEXT SEARCH CONFIGURATION zhparser (PARSER = zhparser);"
    # 这里必须添加 x 才能让自定义词库动态更新生效
    run "ALTER TEXT SEARCH CONFIGURATION zhparser ADD MAPPING FOR n,v,a,i,e,l,j,x WITH simple;"
    run "ALTER role all SET zhparser.multi_short=on;" # 1 短词复合
    run "ALTER role all SET zhparser.multi_duality=on;" # 2 二元复合
    # run "ALTER role all SET zhparser.multi_zmain=on;" # 主要单字复合
    # run "ALTER role all SET zhparser.multi_zall=on;" # 所有单字复合
  end

  down do
    run "ALTER ROLE all RESET ALL"
    run "DROP TEXT SEARCH CONFIGURATION IF EXISTS zhparser;"
    run "DROP EXTENSION IF EXISTS zhparser RESTRICT;"
  end

  # select * from pg_ts_config; # 查看所有的 ts config

  # SELECT ts_parse('zhparser','财联社');
  # SELECT to_tsvector('zhparser','财联社');

  # 刷新 stored generated column 的步骤如下：
  # SELECT * FROM zhparser.zhprs_custom_word;
  # INSERT INTO zhparser.zhprs_custom_word values('中概股') ON CONFLICT DO NOTHING;
  # SELECT sync_zhprs_custom_word();

  # 注意如果改动了 source, 则只有 source 被更新。
  # UPDATE investing_latest_news SET source = source;

  # multi 设定设定分词返回结果时是否复合分割
  #  参数：mode 设定值，1 ~ 15。
  #        按位异或的 1 | 2 | 4 | 8 分别表示: 短词 | 二元 | 主要单字 | 所有单字
  # 例如：
  # SELECT to_tsquery('zhparser','中国人');
  # 默认返回 "中国人", 开启 1 返回：'中国人' & '中国' 开启 1,2, 返回 '中国人' & '中国' & '国人'
  # 开启 1,2,4, 返回  '中国人' & '中国' & '国人' & '国' & '人'

  # 可选的，定期回收空间
  # VACUUM (FULL);
end
