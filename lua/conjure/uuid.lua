local _2afile_2a = "fnl/conjure/uuid.fnl"
local _1_
do
  local name_4_auto = "conjure.uuid"
  local module_5_auto
  do
    local x_6_auto = _G.package.loaded[name_4_auto]
    if ("table" == type(x_6_auto)) then
      module_5_auto = x_6_auto
    else
      module_5_auto = {}
    end
  end
  module_5_auto["aniseed/module"] = name_4_auto
  module_5_auto["aniseed/locals"] = ((module_5_auto)["aniseed/locals"] or {})
  do end (module_5_auto)["aniseed/local-fns"] = ((module_5_auto)["aniseed/local-fns"] or {})
  do end (_G.package.loaded)[name_4_auto] = module_5_auto
  _1_ = module_5_auto
end
local autoload
local function _3_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _3_
local function _6_(...)
  local ok_3f_21_auto, val_22_auto = nil, nil
  local function _5_()
    return {autoload("conjure.aniseed.core")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.uuid"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local v4
do
  local v_23_auto
  do
    local v_25_auto
    local function v40()
      local function _8_(_241)
        return string.format("%x", (((_241 == "x") and math.random(0, 15)) or math.random(8, 11)))
      end
      return string.gsub("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx", "[xy]", _8_)
    end
    v_25_auto = v40
    _1_["v4"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["v4"] = v_23_auto
  v4 = v_23_auto
end
local cats_and_dogs
do
  local v_23_auto = {"Blue Lacy", "Queensland Heeler", "Rhod Ridgeback", "Retriever", "Chinese Sharpei", "Black Mouth Cur", "Catahoula", "Staffordshire", "Affenpinscher", "Afghan Hound", "Airedale Terrier", "Akita", "Australian Kelpie", "Alaskan Malamute", "English Bulldog", "American Bulldog", "American English Coonhound", "American Eskimo Dog", "American Foxhound", "American Hairless Terrier", "American Staffordshire Terrier", "American Water Spaniel", "Anatolian Shepherd Dog", "Basenji", "Basset Hound", "Beagle", "Bearded Collie", "Beauceron", "Bedlington Terrier", "Belgian Malinois", "Belgian Sheepdog", "Belgian Tervuren", "Bergamasco", "Berger Picard", "Bernese Mountain Dog", "Bichon Frise", "Black and Tan Coonhound", "Black Russian Terrier", "Bloodhound", "Bluetick Coonhound", "Boerboel", "Border Collie", "Border Terrier", "Borzoi", "Boston Terrier", "Bouvier des Flandres", "Boxer", "Boykin Spaniel", "Briard", "Brittany", "Brussels Griffon", "Bull Terrier", "Bulldog", "Bullmastiff", "Cairn Terrier", "Canaan Dog", "Cane Corso", "Cardigan Welsh Corgi", "Cavalier King Charles Spaniel", "Cesky Terrier", "Chesapeake Bay Retriever", "Chihuahua", "Chinese Crested Dog", "Chinese Shar Pei", "Chinook", "Chow Chow", "Cirneco dell'Etna", "Clumber Spaniel", "Cocker Spaniel", "Collie", "Coton de Tulear", "Curly-Coated Retriever", "Dachshund", "Dalmatian", "Dandie Dinmont Terrier", "Doberman Pinsch", "Doberman Pinscher", "Dogue De Bordeaux", "English Cocker Spaniel", "English Foxhound", "English Setter", "English Springer Spaniel", "English Toy Spaniel", "Entlebucher Mountain Dog", "Field Spaniel", "Finnish Lapphund", "Finnish Spitz", "Flat-Coated Retriever", "French Bulldog", "German Pinscher", "German Shepherd", "German Shorthaired Pointer", "German Wirehaired Pointer", "Giant Schnauzer", "Glen of Imaal Terrier", "Golden Retriever", "Gordon Setter", "Great Dane", "Great Pyrenees", "Greater Swiss Mountain Dog", "Greyhound", "Harrier", "Havanese", "Ibizan Hound", "Icelandic Sheepdog", "Irish Red and White Setter", "Irish Setter", "Irish Terrier", "Irish Water Spaniel", "Irish Wolfhound", "Italian Greyhound", "Japanese Chin", "Keeshond", "Kerry Blue Terrier", "Komondor", "Kuvasz", "Labrador Retriever", "Lagotto Romagnolo", "Lakeland Terrier", "Leonberger", "Lhasa Apso", "L\195\182wchen", "Maltese", "Manchester Terrier", "Mastiff", "Miniature American Shepherd", "Miniature Bull Terrier", "Miniature Pinscher", "Miniature Schnauzer", "Neapolitan Mastiff", "Newfoundland", "Norfolk Terrier", "Norwegian Buhund", "Norwegian Elkhound", "Norwegian Lundehund", "Norwich Terrier", "Nova Scotia Duck Tolling Retriever", "Old English Sheepdog", "Otterhound", "Papillon", "Parson Russell Terrier", "Pekingese", "Pembroke Welsh Corgi", "Petit Basset Griffon Vend\195\169en", "Pharaoh Hound", "Plott", "Pointer", "Polish Lowland Sheepdog", "Pomeranian", "Standard Poodle", "Miniature Poodle", "Toy Poodle", "Portuguese Podengo Pequeno", "Portuguese Water Dog", "Pug", "Puli", "Pyrenean Shepherd", "Rat Terrier", "Redbone Coonhound", "Rhodesian Ridgeback", "Rottweiler", "Russell Terrier", "St. Bernard", "Saluki", "Samoyed", "Schipperke", "Scottish Deerhound", "Scottish Terrier", "Sealyham Terrier", "Shetland Sheepdog", "Shiba Inu", "Shih Tzu", "Siberian Husky", "Silky Terrier", "Skye Terrier", "Sloughi", "Smooth Fox Terrier", "Soft-Coated Wheaten Terrier", "Spanish Water Dog", "Spinone Italiano", "Staffordshire Bull Terrier", "Standard Schnauzer", "Sussex Spaniel", "Swedish Vallhund", "Tibetan Mastiff", "Tibetan Spaniel", "Tibetan Terrier", "Toy Fox Terrier", "Treeing Walker Coonhound", "Vizsla", "Weimaraner", "Welsh Springer Spaniel", "Welsh Terrier", "West Highland White Terrier", "Whippet", "Wire Fox Terrier", "Wirehaired Pointing Griffon", "Wirehaired Vizsla", "Xoloitzcuintli", "Yorkshire Terrier", "Australian Cattle Dog", "Australian Shepherd", "Australian Terrier", "Abyssinian cat", "Aegean cat", "American Curl", "American Bobtail", "American Shorthair", "American Wirehair", "Arabian Mau", "Australian Mist", "Asian cat", "Asian Semi-longhair", "Balinese cat", "Bambino cat", "Bengal cat", "Birman", "Bombay cat", "Brazilian Shorthair", "British Longhair", "British Shorthair", "British Longhair", "Burmese cat", "Burmilla", "California Spangled", "Chantilly-Tiffany", "Chartreux", "Chausie", "Cheetoh cat", "Colorpoint Shorthair", "Cornish Rex", "Cymric cat", "Cyprus cat", "Devon Rex", "Donskoy cat", "Dragon Li", "Dwarf cat", "Egyptian Mau", "European Shorthair", "Exotic Shorthair", "Foldex cat", "German Rex", "Havana Brown", "Highlander cat", "Himalayan cat", "Japanese Bobtail", "Javanese cat", "Kurilian Bobtail", "Khao Manee", "Korat", "Korean Bobtail", "Korn Ja", "Kurilian Bobtail", "LaPerm", "Lykoi", "Maine Coon", "Manx cat", "Mekong Bobtail", "Minskin", "Munchkin cat", "Nebelung", "Napoleon cat", "Norwegian Forest cat", "Ocicat", "Ojos Azules", "Oregon Rex", "Oriental Bicolor", "Oriental Shorthair", "Oriental Longhair", "PerFold Cat", "Persian cat", "Traditional Persian", "Peterbald", "Pixie-bob", "Raas cat", "Ragamuffin cat", "Ragdoll", "Russian Blue", "Russian White", "Sam Sawet", "Savannah cat", "Scottish Fold", "Selkirk Rex", "Serengeti cat", "Serrade petit cat", "Siamese cat", "Siberian cat", "Singapura cat", "Snowshoe cat", "Sokoke", "Somali cat", "Sphynx cat", "Suphalak", "Thai cat", "Thai Lilac", "Tonkinese cat", "Toyger", "Turkish Angora", "Turkish Van", "Ukrainian Levkoy"}
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["cats-and-dogs"] = v_23_auto
  cats_and_dogs = v_23_auto
end
local pretty
do
  local v_23_auto
  do
    local v_25_auto
    local function pretty0(id)
      local n = tonumber(string.sub(id, 1, 8), 16)
      return a.get(cats_and_dogs, a.inc((n % a.count(cats_and_dogs))))
    end
    v_25_auto = pretty0
    _1_["pretty"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["pretty"] = v_23_auto
  pretty = v_23_auto
end
-- (v4) (pretty (v4))
return nil