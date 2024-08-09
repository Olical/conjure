-- [nfnl] Compiled from fnl/conjure/uuid.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.uuid"
local _2amodule_2a
do
  _G.package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("aniseed.autoload")).autoload
local a, str = autoload("conjure.aniseed.core"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["str"] = str
do local _ = {nil, nil, nil, nil, nil, nil, nil} end
local function v4()
  local function _1_(_241)
    return string.format("%x", (((_241 == "x") and math.random(0, 15)) or math.random(8, 11)))
  end
  return string.gsub("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx", "[xy]", _1_)
end
_2amodule_2a["v4"] = v4
do local _ = {v4, nil} end
local cats_and_dogs = {"Blue Lacy", "Queensland Heeler", "Rhod Ridgeback", "Retriever", "Chinese Sharpei", "Black Mouth Cur", "Catahoula", "Staffordshire", "Affenpinscher", "Afghan Hound", "Airedale Terrier", "Akita", "Australian Kelpie", "Alaskan Malamute", "English Bulldog", "American Bulldog", "American English Coonhound", "American Eskimo Dog", "American Foxhound", "American Hairless Terrier", "American Staffordshire Terrier", "American Water Spaniel", "Anatolian Shepherd Dog", "Basenji", "Basset Hound", "Beagle", "Bearded Collie", "Beauceron", "Bedlington Terrier", "Belgian Malinois", "Belgian Sheepdog", "Belgian Tervuren", "Bergamasco", "Berger Picard", "Bernese Mountain Dog", "Bichon Frise", "Black and Tan Coonhound", "Black Russian Terrier", "Bloodhound", "Bluetick Coonhound", "Boerboel", "Border Collie", "Border Terrier", "Borzoi", "Boston Terrier", "Bouvier des Flandres", "Boxer", "Boykin Spaniel", "Briard", "Brittany", "Brussels Griffon", "Bull Terrier", "Bulldog", "Bullmastiff", "Cairn Terrier", "Canaan Dog", "Cane Corso", "Cardigan Welsh Corgi", "Cavalier King Charles Spaniel", "Cesky Terrier", "Chesapeake Bay Retriever", "Chihuahua", "Chinese Crested Dog", "Chinese Shar Pei", "Chinook", "Chow Chow", "Cirneco dell'Etna", "Clumber Spaniel", "Cocker Spaniel", "Collie", "Coton de Tulear", "Curly-Coated Retriever", "Dachshund", "Dalmatian", "Dandie Dinmont Terrier", "Doberman Pinsch", "Doberman Pinscher", "Dogue De Bordeaux", "English Cocker Spaniel", "English Foxhound", "English Setter", "English Springer Spaniel", "English Toy Spaniel", "Entlebucher Mountain Dog", "Field Spaniel", "Finnish Lapphund", "Finnish Spitz", "Flat-Coated Retriever", "French Bulldog", "German Pinscher", "German Shepherd", "German Shorthaired Pointer", "German Wirehaired Pointer", "Giant Schnauzer", "Glen of Imaal Terrier", "Golden Retriever", "Gordon Setter", "Great Dane", "Great Pyrenees", "Greater Swiss Mountain Dog", "Greyhound", "Harrier", "Havanese", "Ibizan Hound", "Icelandic Sheepdog", "Irish Red and White Setter", "Irish Setter", "Irish Terrier", "Irish Water Spaniel", "Irish Wolfhound", "Italian Greyhound", "Japanese Chin", "Keeshond", "Kerry Blue Terrier", "Komondor", "Kuvasz", "Labrador Retriever", "Lagotto Romagnolo", "Lakeland Terrier", "Leonberger", "Lhasa Apso", "L\195\182wchen", "Maltese", "Manchester Terrier", "Mastiff", "Miniature American Shepherd", "Miniature Bull Terrier", "Miniature Pinscher", "Miniature Schnauzer", "Neapolitan Mastiff", "Newfoundland", "Norfolk Terrier", "Norwegian Buhund", "Norwegian Elkhound", "Norwegian Lundehund", "Norwich Terrier", "Nova Scotia Duck Tolling Retriever", "Old English Sheepdog", "Otterhound", "Papillon", "Parson Russell Terrier", "Pekingese", "Pembroke Welsh Corgi", "Petit Basset Griffon Vend\195\169en", "Pharaoh Hound", "Plott", "Pointer", "Polish Lowland Sheepdog", "Pomeranian", "Standard Poodle", "Miniature Poodle", "Toy Poodle", "Portuguese Podengo Pequeno", "Portuguese Water Dog", "Pug", "Puli", "Pyrenean Shepherd", "Rat Terrier", "Redbone Coonhound", "Rhodesian Ridgeback", "Rottweiler", "Russell Terrier", "St. Bernard", "Saluki", "Samoyed", "Schipperke", "Scottish Deerhound", "Scottish Terrier", "Sealyham Terrier", "Shetland Sheepdog", "Shiba Inu", "Shih Tzu", "Siberian Husky", "Silky Terrier", "Skye Terrier", "Sloughi", "Smooth Fox Terrier", "Soft-Coated Wheaten Terrier", "Spanish Water Dog", "Spinone Italiano", "Staffordshire Bull Terrier", "Standard Schnauzer", "Sussex Spaniel", "Swedish Vallhund", "Tibetan Mastiff", "Tibetan Spaniel", "Tibetan Terrier", "Toy Fox Terrier", "Treeing Walker Coonhound", "Vizsla", "Weimaraner", "Welsh Springer Spaniel", "Welsh Terrier", "West Highland White Terrier", "Whippet", "Wire Fox Terrier", "Wirehaired Pointing Griffon", "Wirehaired Vizsla", "Xoloitzcuintli", "Yorkshire Terrier", "Australian Cattle Dog", "Australian Shepherd", "Australian Terrier", "Abyssinian cat", "Aegean cat", "American Curl", "American Bobtail", "American Shorthair", "American Wirehair", "Arabian Mau", "Australian Mist", "Asian cat", "Asian Semi-longhair", "Balinese cat", "Bambino cat", "Bengal cat", "Birman", "Bombay cat", "Brazilian Shorthair", "British Longhair", "British Shorthair", "British Longhair", "Burmese cat", "Burmilla", "California Spangled", "Chantilly-Tiffany", "Chartreux", "Chausie", "Cheetoh cat", "Colorpoint Shorthair", "Cornish Rex", "Cymric cat", "Cyprus cat", "Devon Rex", "Donskoy cat", "Dragon Li", "Dwarf cat", "Egyptian Mau", "European Shorthair", "Exotic Shorthair", "Foldex cat", "German Rex", "Havana Brown", "Highlander cat", "Himalayan cat", "Japanese Bobtail", "Javanese cat", "Kurilian Bobtail", "Khao Manee", "Korat", "Korean Bobtail", "Korn Ja", "Kurilian Bobtail", "LaPerm", "Lykoi", "Maine Coon", "Manx cat", "Mekong Bobtail", "Minskin", "Munchkin cat", "Nebelung", "Napoleon cat", "Norwegian Forest cat", "Ocicat", "Ojos Azules", "Oregon Rex", "Oriental Bicolor", "Oriental Shorthair", "Oriental Longhair", "PerFold Cat", "Persian cat", "Traditional Persian", "Peterbald", "Pixie-bob", "Raas cat", "Ragamuffin cat", "Ragdoll", "Russian Blue", "Russian White", "Sam Sawet", "Savannah cat", "Scottish Fold", "Selkirk Rex", "Serengeti cat", "Serrade petit cat", "Siamese cat", "Siberian cat", "Singapura cat", "Snowshoe cat", "Sokoke", "Somali cat", "Sphynx cat", "Suphalak", "Thai cat", "Thai Lilac", "Tonkinese cat", "Toyger", "Turkish Angora", "Turkish Van", "Ukrainian Levkoy"}
_2amodule_locals_2a["cats-and-dogs"] = cats_and_dogs
do local _ = {nil, nil} end
local function pretty(id)
  if a["string?"](id) then
    local n = tonumber(string.sub(id, 1, 8), 16)
    return a.get(cats_and_dogs, a.inc((n % a.count(cats_and_dogs))))
  else
    return str.join({"<conjure.uuid: got ", type(id), " not string, this is a bug!>"})
  end
end
_2amodule_2a["pretty"] = pretty
do local _ = {pretty, nil} end
--[[ (v4) (pretty (v4)) ]]
return _2amodule_2a
