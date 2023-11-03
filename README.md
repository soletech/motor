[![test status](https://github.com/soletech/motor/workflows/Test/badge.svg)](https://github.com/soletech/motor/actions?query=workflow%3ATest)
[![lint status](https://github.com/soletech/motor/workflows/Lint/badge.svg)](https://github.com/soletech/motor/actions?query=workflow%3ALint)

# Motor

Depo bir program ve Web uygulamasında kullanılacak bir kitaplık sunuyor.

- `bin/motor`: Python ile çözümleme yapan ana program. Bu programı (test hariç) doğrudan kullanmak yerine `Motor`
  kitaplığıyla kullanıyoruz.

- `lib/motor`: Web uygulamasında kullanılacak ana kitaplık.

## Kurulum

**Dikkat!** Ruby sürümü >= 3.2, Python sürümü >= 3.11 olmalı.

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

- Test

  ```sh
  bundle exec rake test
  ```

- Lint (Ruby ve Python kodlarını denetler)

  ```sh
  bundle exec rake lint
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
alanı hata kodunu, `message` ise hata açıklamasını içerir.

Sadece başarılı bir çözümle ilgileniyorsanız `solve!` metodunun aşağıdaki örnekteki gibi kullanılması önerilir:

```ruby
require "motor"

def ilgili_metot(...)
  request = ...                     # JSON string ver
  response = Motor.solve!(request)  # Çöz ve JSON string al
  ...                               # Çözüm başarılı, response'u işle      
rescue Motor::Error => e
  # Hata iletisi e.message ile hatayı yönet
  ...
end
```


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
        "message": <HATA MESAJI: String>,
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
