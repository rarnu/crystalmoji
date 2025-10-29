require "../spec_helper"
require "uuid"

describe Crystalmoji do

  num_threads = 10
  per_thread_runs = 50000
  key_set_size = 1000

  channels = Array(Channel(Nil)).new
  randoms = Array(String).new
  trie = CrystalMoji::Trie::PatriciaTrie(Int32).new

  # 初始化数据
  key_set_size.times do |i|
    random = UUID.random.to_s
    randoms << random
    trie[random] = i
  end

  # 创建并启动线程
  num_threads.times do
    channel = Channel(Nil).new

    spawn do
      per_thread_runs.times do
        random_index = rand(randoms.size)
        random = randoms[random_index]

        # 测试检索
        trie[random].should eq(random_index)

        random_prefix_length = rand(random.size)

        # 测试随机前缀匹配
        trie.contains_key_prefix?(random[0, random_prefix_length]).should be_true
      end
      channel.send(nil)
    end

    channels << channel
  end

  # 等待所有线程完成
  channels.each(&.receive)
end
