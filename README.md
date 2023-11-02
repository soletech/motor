[![test status](https://github.com/soletech/motor/workflows/Test/badge.svg)](https://github.com/soletech/motor/actions?query=workflow%3ATest)
[![lint status](https://github.com/soletech/motor/workflows/Lint/badge.svg)](https://github.com/soletech/motor/actions?query=workflow%3ALint)

# Motor

Depo bir program ve Web uygulamasında kullanılacak bir kitaplık sunuyor.

- `bin/motor`: Python ile çözümleme yapan ana program. Bu programı (test hariç) doğrudan kullanmak yerine `Motor`
  kitaplığıyla kullanıyoruz.

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

### Entegrasyon

Çözümlenecek veriyi JSON biçiminde `request` adıyla `Motor`'a gönderen ve sonucu `response` adıyla alan örnek kod:

```ruby
require "motor"

request = ...                    # JSON string ver
response = Motor.solve(request)  # Çöz ve JSON string al
```

Geçerli (optimal) bir çözüm elde edilmişse cevap verisinde `success` alanı `true` değerini alır.  Aksi tüm durumlarda
`success` alanı `false` değerindedir ve sorunu görmek için `status` durum alanına bakılır.  Durum bilgisinde `code`
alanı hata kodunu, `desc` ise hata açıklamasını içerir.

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
    "success": <ÇÖZÜMÜN BAŞARISI: Bool>,
    "status": {
        "code": <HATA KODU: String>,
        "desc": <HATA AÇIKLAMASI: String>,
    },
    "response": { # Optimal Çözüm ve Duyarlılık Değerleri
        "solution": <ÇÖZÜM: Float>,
        "sensitivity": { # Duyarlık çözümlemesi sonuçları
            "coeff": [
                ...
            ],
            "bound": [
                ...
            ]
        }
    },
    "request": <REQUEST VERİSİ: Hash>
}
```
