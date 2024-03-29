require 'digest/sha2'
require 'json'

require_relative 'block'

class BlockChain
  attr_reader :blocks

  def initialize
    @blocks = []
    @blocks << BlockChain.get_genesis_block
  end

  def last_block
    @blocks.last
  end

  def next_block transactions
    height = last_block.height + 1
    timestamp = Time.now.to_i
    previous_hash = last_block.hash
    pow = ProofOfWork.new(
      timestamp: timestamp,
      previous_hash: previous_hash,
      transactions: transactions
    )

    nonce, hash = pow.do_proof_of_work

    block = Block.new(
      hash: hash,
      height: height,
      transactions: transactions,
      timestamp: timestamp,
      nonce: nonce,
      previous_hash: previous_hash
    )
  end

  def add_block new_block
    if is_valid_new_block?(new_block, last_block)
      @blocks << new_block
    end
  end

  def size
    @blocks.size
  end

  def is_valid_new_block? new_block, previous_block
    if previous_block.height + 1 != new_block.height
      puts "invalid height"
      return false
    elsif previous_block.hash != new_block.previous_hash
      puts "Invalid hash: previous hash"
      return false
    elsif calculate_hash_for_block(new_block) != new_block.hash
      puts "invalid hash: hash"
      puts calculate_hash_for_block(new_block)
      puts new_block.hash
      return false
    end
    true
  end

  def self.get_genesis_block
    Block.create_genesis_block
  end

  def self.is_valid_chain? block_chain_to_validate
    return false if block_chain_to_validate.blocks[0] != BlockChain.get_genesis_block()
    tmp_blocks = [block_chain_to_validate.bloks[0]]
    block_chain_to_validate.blocks[1..-1].each.with_index(1) do |block, i|
      if block_chain_to_validate.is_valid_new_block?(block, tmp_blocks[i - 1])
        tmp_blocks << block
      else
        return false
      end
    end
  end

  private
    def calculate_hash_for_block block
      Digest::SHA256.hexdigest({
        timestamp: block.timestamp,
        transactions: block.transactions,
        previous_hash: block.previous_hash,
        nonce: block.nonce
      }.to_json)
    end
end