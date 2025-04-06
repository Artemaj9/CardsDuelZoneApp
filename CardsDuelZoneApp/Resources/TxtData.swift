//
//  TxtData.swift
//

import Foundation

enum Txt {
  static let welcomeTitle = [
    "Welcome to the world of \nstrategic card battles!",
    "Control the zones – Multiply your winnings!",
  ]
  
  static let welcDescr = [
    "Experience a brand-new game mechanic where it's not just about playing the right cards but also about controlling zones! Plan your moves, outmaneuver your opponent, and secure the highest multiplier!",
    "A zone is claimed by the player who places the last card in it. The more cards in a zone, the higher the multiplier! And the Joker? It's your secret weapon, guaranteeing victory in the chosen zone."
  ]
  
  static let dot = "\u{2022}"
  
  enum Info {
    static let intro = "This is a strategic card game with a unique zone control mechanic and dynamic multipliers. Players compete by placing cards into three different zones, aiming to have the last card in a zone, which determines the winner for that zone."
    
    static let zones = [
      "🔴 Red Zone – for cards 2–6.",
      "🟡 Yellow Zone – for cards 7–10.",
      "🔵 Blue Zone – for cards J, Q, K, A.",
      "Joker can be played in any zone and guarantees victory in that zone while preserving its current multiplier.",
      "Winning cards in a zone earn points based on their value and the zone's multiplier, which increases as more cards are placed."
    ]
    
    static let features = [
      "✓ Tactical gameplay – choosing the right zones and cards requires strategy.",
      "✓ Dynamic multipliers – the more cards in a zone, the higher the final payout.",
      "✓ Joker – the ultimate trump card – grants 100% control over a zone.",
      "✓ Competitive mode – play against AI or real opponents.",
      "✓ Intuitive interface – easy to learn, deep in strategy."
    ]
    
    static let discl = "This product is intended for entertainment purposes only. The game uses virtual currency, which has no real monetary value and cannot be exchanged for real money, securities, goods, or services."
    
    static let points = [
      "The game does not offer any form of cash winnings.",
      "Purchasing virtual currency does not grant the right to refunds or exchanges for real-world funds.",
      "The game does not support cash withdrawals in any form."
    ]
    
    static let outlog = "This project is designed for entertainment and does not promote gambling involving real stakes. Please play responsibly."
  }
}
