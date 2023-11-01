[![test status](https://github.com/soletech/motor/workflows/Test/badge.svg)](https://github.com/soletech/motor/actions?query=workflow%3ATest)
[![lint status](https://github.com/soletech/motor/workflows/Lint/badge.svg)](https://github.com/soletech/motor/actions?query=workflow%3ALint)

# Motor

Depo iki program ve Web uygulamasında kullanılacak bir kitaplık sunuyor.

- `bin/motor`: Python ile çözümleme yapan ana program. Bu programı (test hariç) doğrudan kullanmak yerine `Motor`
  kitaplığıyla kullanıyoruz.

- `bin/rotor`: Ruby ile (kitaplık üzerinden) `rotor`'u çalıştıran program.  Bu programı sadece test yapmak için
  kullanın.

- `lib/motor`: Web uygulamasında kullanılacak ana kitaplık.

## Kurulum

### Konuşlandırma

- Gerekli Python paketlerini kur

  ```sh
  sudo apt install python3-swiglpk python3-numpy
  ```

- Rails'a `motor` Gem'ini ekle ve `bundle install` yap

### Geliştirme

Depoyu klonladıktan sonra

- Gerekli Python paketlerini kur (bk. Konuşlandırma)


- Bundle kurulumu yap

  ```sh
  bundle config set --local path vendor/bundle
  bundle install
  ```

- Test et

  ```sh
  bundle exec rake test
  ```

## Kullanım

### Geliştirme

Elle deneme yapmak için:

```sh
bin/motor <JSON BİÇİMİNDE İSTEK DOSYASI> <JSON BİÇİMİNDE ÇIKTI DOSYASI ADI>
```

Ruby entegrasyonunu denemek için

```sh
bin/rotor <JSON BİÇİMİNDE İSTEK DOSYASI> # çıktı stdout
```

### Entegrasyon

Çözümlenecek veriyi JSON biçiminde `request` adıyla `Motor`'a gönderen ve sonucu `response` adıyla alan örnek kod:

```ruby
require "motor"

request = ...                       # JSON string ver
Motor.validate(request)             # Doğrulama yap
response = Motor.response(request)  # Analiz yap
... response.json                   # JSON string al
```

Çözümlemede oluşacak hataları görmek için `motor` programının tam çıktısını taşıyan `response.shell` değerini
okuyabilirsiniz.

- `response.shell.to_s`: `motor` programının STDOUT çıktısı.
- `response.shell.err`: `motor` programının STDERR'de görüntülediği satırlar (bir dizi).
- `response.shell.exit_code`: `motor` programının sonlanma kodu.

## Şema

### Request

```json
{
    "name": <ANALİZ_ADI: String>,

    "variables":  [ # Değişkenler dizisi
        <DEĞİŞKEN ADI: String>,
        ...
    ],

    "objective": { # Amaç fonksiyonu (katsayıları)
        "name": <AMAÇ ADI: String>,
        "coefficients": [
            <KATSAYI: Float>,
            ...
        ]
    },

    "constraints": [ # Kısıtlar dizisi
         { # Kısıt
           "name": <KISIT ADI: String>,
           "coefficients": [
               <KATSAYI: Float>,
               ...
           ],
           "relation": <İLİŞKİ: String (<=, >=, ==, <, >)>
           "rhs": <EŞİTLİĞİN SAĞ TARAFI: Float>
         },

          ...
    ]
}
```

### Response

```json
{
    "data": <REQUEST VERİSİ: Hash>
    "result": { # Optimal Çözüm ve Duyarlılık Değerleri
        "solution": <ÇÖZÜM: Float>,
        "sensitivity": { # Duyarlık çözümlemesi sonuçları
            "coeff": [
                ...
            ],
            "bound": [
                ...
            ]
        }
    }
}
```
