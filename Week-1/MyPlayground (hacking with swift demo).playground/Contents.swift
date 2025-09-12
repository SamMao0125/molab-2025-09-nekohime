import Cocoa

var greeting = "Hello, playground"

var name = "Sam"
name = "Sammy"
name = "Sammy Sam"

let actor = "Swag Mao"

var playerName = "Ray"
print(playerName)

playerName = "Sam"
print(playerName)

playerName = "Rayyy"
print(playerName)

let dayInLife = """
nya
nyaa
nyaaa
"""

print(actor.count)
print(actor.uppercased())

let score = 10
let bigNumber = 1_000_000_000_000_000
let bigStrangeNumber = 1000__000___000_00

let smallBigNumber = bigNumber - 10000

var counter = 50
counter += 70
print(counter)

let number = 120
print(number.isMultiple(of: 3))

let numberExample = 0.1 + 0.2
print(numberExample)

var nameExample = "Nicolas Cage"
nameExample = "58"

let filename = "paris.jpg"
print(filename.hasSuffix(".jpg"))

let goodKitties = true
let gameOver = false
let isMultiple = 120.isMultiple(of: 3)

let orangeCat = "Naughty"
let ragdollCat = "Elegant"
let persianCat = "Cuddly"
let catTraits = "Orange kitties are " + orangeCat + ", ragdolls are " + ragdollCat + ", and persian cats are " + persianCat
print (catTraits)

let catExplaning = "Nyaaaa, I'm an \(ragdollCat) ragdoll kitty!"
// keep in mind it is "\" not "/"
print(catExplaning)

// Checkpoint 1

let Celsius = 5
let Fahrenheit = (Celsius * 9/5) + 32
print("\(Celsius) degrees Celsius is equal to \(Fahrenheit) degrees Fahrenheit.")

var beatles = ["John", "Paul", "George", "Ringo"]
let numbers = [4, 8, 10, 12, 14, 16, 18, 20]
print(beatles[2])
// array starts with 0, not 1
beatles.append("A-Ray")

var scores = Array<Double>()
// <for specialization like Double, Int, String>
// could also be written as var scores = [Double]
scores.append(88.5)
scores.append(92.0)
scores.append(94.0)
scores.append(89.5)

print(scores)
    
let employee2 = ["name": "Taylor Swift", "job": "Singer", "location": "New York"]
print(employee2["name", default: "Unknown"])
print(employee2["location", default: "Unknown"])
print(employee2["job", default: "Unknown"])

let watches = ["swiss": "Urwerk", "german": "Lange", "russian": "Chaykin"]

print(watches["swiss", default: "Unknown"])

// use enum for when there is a set number of choices
enum CatTypes {
    case siamese
    case ragdoll
    case tuxedo
    case pirussian
    
    // or write like this, and btw variable is fixed
    case shorthair, orange, black, white
}

var cat = CatTypes.ragdoll
cat = CatTypes.tuxedo
// shorthand
cat = .black

print(cat)

let ragdoll: String = "lovely"
var IndependentWatchMakers: [String] = ["Urwerk", "MB&F", "H Moser & Cie"]

// Checkpoint 2

let wristwatches = ["Urwerk", "MB&F", "H Moser & Cie"]
print(wristwatches.count)


