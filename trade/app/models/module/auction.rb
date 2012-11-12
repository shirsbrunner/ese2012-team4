module Models
  class Auction
    attr_accessor :item, :owner, :increment, :min_prize, :end_time, :bids, :current_winner, :current_selling_price

    def self.create(owner, item, increment, min_prize, end_time)
      self.item= item
      self.owner= owner
      self.increment= increment
      self.min_prize= min_prize
      self.end_time= end_time
      @bids = Hash.new(-10000)
    end

    def place_bid(owner, price)
      return :not_enough_credits if owner.credits < price
      return :invalid_bid if @bids[owner] > price or price <= self.min_prize
      return :bid_already_made if @bids.values.detect {|bid| bid==price}
      @bids[owner] = price
      update_current_winner
      return :success
    end

    def update_current_winner
      temp_winner = nil
      @current_winner.credits += @bids[@current_winner] #SH Gives the money of the previous winner back

      @bids.each{ |owner, price|
        if @bids[temp_winner] < price
          temp_winner = owner
        end
      }

      @current_winner = temp_winner
      @current_winner.credits -= @bids[@current_winner] #SH Deduct the money from the current winner
      @current_selling_price = @bids[@current_winner]-1 + increment
    end
  end
end