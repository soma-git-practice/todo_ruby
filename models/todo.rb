class Todo < Common
  def self.arrange_time(year,month,day,hour,min)
    Time.new(year, month, day, hour, min).strftime('%Y-%m-%d %H:%M')
  end

  # 初期データ作成
  def self.setup
    # テーブルが存在していれば
    return unless connection.table_exists?(:todos)
    # DB内にレコードが存在しない場合のみ
    return if all.present?
    create(subject: 'Aさん', place: 'A書店', object: '本', verb: 'A冊買う', s_time: arrange_time(2023, 12, 17, 13, 0), e_time: arrange_time(2023, 12, 17, 13, 30))
    create(subject: 'Bさん', place: 'B書店', object: '本', verb: 'B冊買う', s_time: arrange_time(2023, 12, 17, 14, 0), e_time: arrange_time(2024, 12, 17, 14, 30))
    create(subject: 'Cさん', place: 'C書店', object: '本', verb: 'C冊買う', s_time: arrange_time(2024, 12, 17, 15, 0), e_time: arrange_time(2024, 12, 17, 15, 30))
  end

  HEADER = { id: 'ID', subject: 'だれが', place: 'どこで', object: 'なにを', verb: 'どうする', s_time: 'いつから', e_time: 'いつまで', delete: '削除' }

  # エクスポート関連
  # def self.export
  #   # テーブルが作成されていない場合引き返す
  #   return unless connection.table_exists?(:todos)
  #   # DB内にレコードが存在しない場合引き返す
  #   return unless all.present?

  #   FileUtils.mkdir_p('csv/exports')
  #   file_name = "csv/exports/e#{ Time.now.strftime('%Y%m%d%H%M%S') }.csv"
  #   CSV.open(file_name, 'w') do |csv|
  #     csv << HEADER.values
  #     all.each{ |row| csv << row.attributes.values }
  #   end
  # end

  # インポート関連
  def self.import(file_path)
    # テーブルが作成されていない場合引き返す
    return unless connection.table_exists?(:todos)

    CSV.open("csv/imports/#{file_path}", 'r', headers: true).each do |csv|
      if csv['ID'].present? && csv['削除'].present?
        # 削除
        if find(csv['ID'])
          destroy(csv['ID'])
          puts "#{csv['ID']}を削除しました"
        else
          puts "#{csv['ID']}に変更はありません"
        end
      elsif csv['ID'].present?
        # 編集
        target = find(csv['ID'])
        update_attributes = Hash.new
        update_message_words = Array.new
        target_symbol_keys = target.attributes.symbolize_keys.keys
        target_symbol_keys.each do |sym|
                    # シンボルによる登録条件の分岐
                    case sym
                      when :id
                        conditions = false
                      when :s_time, :e_time
                        conditions = csv[HEADER[sym]] != target[sym]
                      else
                        conditions = csv[HEADER[sym]].present? && csv[HEADER[sym]] != target[sym]
                    end
                    # 登録情報、メッセージを設定
                    if conditions
                      update_attributes[sym] = csv[HEADER[sym]]
                      update_message_words << HEADER[sym]
                    end
                  end
        target.update(update_attributes)
        puts "#{csv['ID']}を編集しました #{update_message_words}" if update_message_words.present?
        puts "#{csv['ID']}に変更はありません" if update_message_words.blank?
      else
        # 新規作成
        create_attributes = Hash.new
        attributes_keys = HEADER.except(:id, :delete).keys
        attributes_keys.each{ |sym| create_attributes[sym] = csv[HEADER[sym]]}
        create(**create_attributes)
        puts "新規作成しました"
      end
    end
  end

end