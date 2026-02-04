class BlackjackEngine {
  constructor() {
    this.games = new Map();
  }

  generateId() {
    return Math.random().toString(36).substr(2, 9);
  }

  createDeck() {
    const suits = ['H', 'D', 'C', 'S'];
    const values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
    let deck = [];
    for (let suit of suits) {
      for (let value of values) {
        deck.push({ suit, value });
      }
    }
    return this.shuffle(deck);
  }

  shuffle(deck) {
    for (let i = deck.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [deck[i], deck[j]] = [deck[j], deck[i]];
    }
    return deck;
  }

  calculateScore(hand) {
    let score = 0;
    let aces = 0;
    for (let card of hand) {
      if (['J', 'Q', 'K'].includes(card.value)) {
        score += 10;
      } else if (card.value === 'A') {
        aces += 1;
        score += 11;
      } else {
        score += parseInt(card.value);
      }
    }
    while (score > 21 && aces > 0) {
      score -= 10;
      aces -= 1;
    }
    return score;
  }

  getPublicState(gameState) {
    // Hide dealer's second card if game is active
    const dealerVisible = gameState.status === 'active' 
      ? [gameState.dealerHand[0], { suit: '?', value: '?' }] 
      : gameState.dealerHand;

    return {
      gameId: gameState.id,
      playerId: gameState.playerId,
      bet: gameState.bet,
      playerHand: gameState.playerHand,
      dealerHand: dealerVisible,
      playerScore: this.calculateScore(gameState.playerHand),
      dealerScore: gameState.status === 'active' ? '?' : this.calculateScore(gameState.dealerHand),
      status: gameState.status,
      message: gameState.message,
      winnings: gameState.winnings
    };
  }

  startGame(playerId, betAmount) {
    const gameId = this.generateId();
    const deck = this.createDeck();
    const playerHand = [deck.pop(), deck.pop()];
    const dealerHand = [deck.pop(), deck.pop()];
    
    const gameState = {
      id: gameId,
      playerId,
      bet: betAmount,
      deck,
      playerHand,
      dealerHand,
      status: 'active',
      message: 'Your turn',
      winnings: 0
    };

    // Check for instant Blackjack
    const playerScore = this.calculateScore(playerHand);
    const dealerScore = this.calculateScore(dealerHand);

    if (playerScore === 21) {
      if (dealerScore === 21) {
        gameState.status = 'push';
        gameState.message = 'Push (Both have Blackjack)';
        gameState.winnings = betAmount;
      } else {
        gameState.status = 'player_won_blackjack';
        gameState.message = 'Blackjack! You win 3:2';
        gameState.winnings = betAmount * 2.5;
      }
    }

    this.games.set(gameId, gameState);
    return this.getPublicState(gameState);
  }

  hit(gameId) {
    const game = this.games.get(gameId);
    if (!game || game.status !== 'active') {
      throw new Error('Game not found or finished');
    }

    game.playerHand.push(game.deck.pop());
    const score = this.calculateScore(game.playerHand);

    if (score > 21) {
      game.status = 'dealer_won';
      game.message = 'Bust! You went over 21.';
      game.winnings = 0;
    }

    this.games.set(gameId, game);
    return this.getPublicState(game);
  }

  stand(gameId) {
    const game = this.games.get(gameId);
    if (!game || game.status !== 'active') {
      throw new Error('Game not found or finished');
    }

    // Dealer turn
    let dealerScore = this.calculateScore(game.dealerHand);
    while (dealerScore < 17) {
      game.dealerHand.push(game.deck.pop());
      dealerScore = this.calculateScore(game.dealerHand);
    }

    const playerScore = this.calculateScore(game.playerHand);

    if (dealerScore > 21) {
      game.status = 'player_won';
      game.message = 'Dealer busts! You win.';
      game.winnings = game.bet * 2;
    } else if (dealerScore > playerScore) {
      game.status = 'dealer_won';
      game.message = 'Dealer wins.';
      game.winnings = 0;
    } else if (dealerScore < playerScore) {
      game.status = 'player_won';
      game.message = 'You win!';
      game.winnings = game.bet * 2;
    } else {
      game.status = 'push';
      game.message = 'Push.';
      game.winnings = game.bet;
    }

    this.games.set(gameId, game);
    return this.getPublicState(game);
  }
}

module.exports = new BlackjackEngine();
