[![test status](https://github.com/soletech/motor/workflows/Test/badge.svg)](https://github.com/soletech/motor/actions?query=workflow%3ATest)
[![lint status](https://github.com/soletech/motor/workflows/Lint/badge.svg)](https://github.com/soletech/motor/actions?query=workflow%3ALint)

# Motor

Depo bir program ve Web uygulamasında kullanılacak bir kitaplık sunuyor.

- `bin/motor`: Python ile çözümleme yapan ana program. Bu programı (test hariç) doğrudan kullanmak yerine `Motor`
  kitaplığı veya `rotor` sarmalayıcı programı üzerinden kullanıyoruz.

- `bin/rotor`: Çözümleme verisini JSON veya XLSX biçiminde alıp (JSON biçiminde) doğrulanmış olarak `motor`'a veren ve
  çözümleme sonucunu JSON veya XLSX biçiminde kaydeden "sarmalayıcı" program.

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

Sarmalayıcı programı ("rotor") denemek için:

```sh
bundle exec bin/rotor problem.json # Çıktı JSON biçiminde stdout'ta (ekranda) görüntülenilir
bundle exec bin/rotor problem.json  solution.xlsx # Çıktı Excel dosyasında
```

Okuma ve yazmada kullanılacak veri biçimi (json veya xlsx) dosya uzantılarından otomatik belirlenir. Veri biçimlerini
açık şekilde vermek için:

```sh
bundle exec bin/rotor -r json -w xlsx input output # JSON oku, çözümle, Excel dosyasına yaz
```

Çözümleme yapmadan sadece veri biçimlerini dönüştürmek için:

```sh
bundle exec bin/rotor -c data.json data.xlsx # JSON'dan Excel'e çevir
```

Doğrudan çözümleme yapan (Python ile yazılmış) programı ("motor") elle denemek için:

```sh
bin/motor <JSON BİÇİMİNDE İSTEK DOSYASI> <JSON BİÇİMİNDE ÇIKTI DOSYASI ADI>
```

### Entegrasyon

Çözümlenecek girdi dosyasını, çıktı dosyasını ve bu dosyaların veri biçimlerini belirliyor ve `read_solve_write`
metodunu çağırıyoruz. Örnekte girdi ve çıktı Excel biçiminde (aynı biçimde olması gerekmiyor):

```ruby
require "motor"

begin
  Motor.read_solve_write(input_file, output_file, read: :xlsx, write: :xlsx)
  # Başarılı, çözüm çıktı dosyasında
rescue Motor::Error => e
  # Başarısız, hata iletisi e.message ile hatayı yönet
end
```

Çözümü geçici bir dosyaya yazarak dosyayı blok içinde işlemek istersek:

```ruby
require "motor"

Motor.read_solve_process(input_file, read: :xlsx, write: :xlsx) do |tempfile|
  # Başarılı, çözüm geçici dosya tutamacında.
  # tempfile.read ile dosyayı okuyabilir, tempfile.path ile yolunu öğrenebiliriz.
rescue Motor::Error => e
  # Başarısız, hata iletisi e.message ile hatayı yönet
end
# Blok sonunda tempfile yok edilir, özel bir işleme gerek yok.
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
    <REQUEST VERİSİ: Hash>,

    "solution": {
        "success": <ÇÖZÜMÜN BAŞARISI: Bool>,
        "result": {
            "value": <ÇÖZÜM: Float>,
            "code": <HATA KODU: String>,
            "message": <HATA MESAJI: String>,
        },
        # Duyarlık çözümlemesi sonuçları
        "coefficients": [
            ...
        ],
        "boundaries": [
            ...
        ]
    }
}
```
