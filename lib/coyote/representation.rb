module Coyote
  # Utility functions for managing Representations
  module Representation
    # Enumerates all states that a Representation can be in, corresponding to the database's
    # resource_status enum
    STATUSES = {
      ready_to_review: 'ready_to_review',
      approved:        'approved',
      not_approved:    'not_approved'
    }.freeze

    # A list of MIME types for which Coyote accepts representations
    # @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Complete_list_of_MIME_types
    # @see https://www.iana.org/assignments/media-types/media-types.xhtml
    CONTENT_TYPES = %w[
      text/plain
      text/html
      audio/mp3
      audio/ogg
      audio/midi
      audio/webm
      audio/3gpp
      audio/3gpp2
      image/gif
      image/png
      image/jpeg
      image/tiff
      image/svg+xml
      video/mpeg
      video/ogg
      video/webm
      video/3gpp
      video/3gpp2
    ].freeze
    
    LANGUAGES = {
      "English" => "en",
      "Abkhazian" => "ab",
      "Afar" => "aa",
      "Afrikaans" => "af",
      "Albanian" => "sq",
      "Amharic" => "am",
      "Arabic" => "ar",
      "Aragonese" => "an",
      "Armenian" => "hy",
      "Assamese" => "as",
      "Aymara" => "ay",
      "Azerbaijani" => "az",
      "Bashkir" => "ba",
      "Basque" => "eu",
      "Bengali (Bangla)" => "bn",
      "Bhutani" => "dz",
      "Bihari" => "bh",
      "Bislama" => "bi",
      "Breton" => "br",
      "Bulgarian" => "bg",
      "Burmese" => "my",
      "Byelorussian (Belarusian)" => "be",
      "Cambodian" => "km",
      "Catalan" => "ca",
      "Cherokee" => "chr",
      "Chewa" => "nya",
      "Chinese" => "zh",
      "Chinese (Simplified)" => "zh-Hans",
      "Chinese (Traditional)" => "zh-Hant",
      "Corsican" => "co",
      "Croatian" => "hr",
      "Czech" => "cs",
      "Danish" => "da",
      "Divehi" => "div",
      "Dutch" => "nl",
      "Edo" => "bin",
      "Esperanto" => "eo",
      "Estonian" => "et",
      "Faeroese" => "fo",
      "Farsi" => "fa",
      "Fiji" => "fj",
      "Finnish" => "fi",
      "French" => "fr",
      "Frisian" => "fy",
      "Fulfulde" => "ful",
      "Galician" => "gl",
      "Gaelic (Scottish)" => "gd",
      "Gaelic (Manx)" => "gv",
      "Georgian" => "ka",
      "German" => "de",
      "Greek" => "el",
      "Greenlandic" => "kl",
      "Guarani" => "gn",
      "Gujarati" => "gu",
      "Haitian Creole" => "ht",
      "Hausa" => "ha",
      "Hawaiian" => "haw",
      "Hebrew" => "he",
      "Hindi" => "hi",
      "Hungarian" => "hu",
      "Icelandic" => "is",
      "Ido" => "io",
      "Igbo" => "ibo",
      "Indonesian" => "in",
      "Interlingua" => "ia",
      "Interlingue" => "ie",
      "Inuktitut" => "iu",
      "Inupiak" => "ik",
      "Irish" => "ga",
      "Italian" => "it",
      "Japanese" => "ja",
      "Javanese" => "jv",
      "Kannada" => "kn",
      "Kanuri" => "kau",
      "Kashmiri" => "ks",
      "Kazakh" => "kk",
      "Kinyarwanda (Ruanda)" => "rw",
      "Kirghiz" => "ky",
      "Kirundi (Rundi)" => "rn",
      "Konkani" => "kok",
      "Korean" => "ko",
      "Kurdish" => "ku",
      "Laothian" => "lo",
      "Latin" => "la",
      "Latvian (Lettish)" => "lv",
      "Limburgish ( Limburger)" => "li",
      "Lingala" => "ln",
      "Lithuanian" => "lt",
      "Macedonian" => "mk",
      "Malagasy" => "mg",
      "Malay" => "ms",
      "Malayalam" => "ml",
      "Maltese" => "mt",
      "Maori" => "mi",
      "Marathi" => "mr",
      "Moldavian" => "mo",
      "Mongolian" => "mn",
      "Nauru" => "na",
      "Nepali" => "ne",
      "Norwegian" => "no",
      "Occitan" => "oc",
      "Oriya" => "or",
      "Oromo (Afaan Oromo)" => "om",
      "Papiamentu" => "pap",
      "Pashto (Pushto)" => "ps",
      "Polish" => "pl",
      "Portuguese" => "pt",
      "Punjabi" => "pa",
      "Quechua" => "qu",
      "Rhaeto-Romance" => "rm",
      "Romanian" => "ro",
      "Russian" => "ru",
      "Samoan" => "sm",
      "Sangro" => "sg",
      "Sanskrit" => "sa",
      "Serbian" => "sr",
      "Serbo-Croatian" => "sh",
      "Sesotho" => "st",
      "Setswana" => "tn",
      "Shona" => "sn",
      "Sichuan Yi" => "ii",
      "Sindhi" => "sd",
      "Sinhalese" => "si",
      "Siswati" => "ss",
      "Slovak" => "sk",
      "Slovenian" => "sl",
      "Somali" => "so",
      "Sundanese" => "su",
      "Swahili (Kiswahili)" => "sw",
      "Swedish" => "sv",
      "Syriac" => "syr",
      "Tagalog" => "tl",
      "Tajik" => "tg",
      "Tamazight" => "zgh",
      "Tamil" => "ta",
      "Tatar" => "tt",
      "Telugu" => "te",
      "Thai" => "th",
      "Tibetan" => "bo",
      "Tigrinya" => "ti",
      "Tonga" => "to",
      "Tsonga" => "ts",
      "Turkish" => "tr",
      "Turkmen" => "tk",
      "Twi" => "tw",
      "Uighur" => "ug",
      "Ukrainian" => "uk",
      "Urdu" => "ur",
      "Uzbek" => "uz",
      "Venda" => "ven",
      "Vietnamese" => "vi",
      "Volapük" => "vo",
      "Wallon" => "wa",
      "Welsh" => "cy",
      "Wolof" => "wo",
      "Xhosa" => "xh",
      "Yiddish yi," => "yi",
      "Yoruba" => "yo",
      "Zulu" => "zu"
    }.freeze

    module_function

    # Iterates through all possible statuses
    # @yieldparam human_friendly_status [String]
    # @yieldparam status [Symbol]
    def self.each_status
      STATUSES.each_key do |status|
        yield status.to_s.titleize, status
      end
    end

    # @return [Array<Symbol>] list of all available statuses
    def self.status_names
      STATUSES.keys
    end
  end
end
