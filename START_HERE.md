# CASE 003 — The Delivery Dilemma

## Mulai di sini

Ekstrak ZIP, buka folder di VS Code, lalu hubungkan SQLTools SQLite ke data/ponte_case_003.db. Tidak perlu menjalankan Python atau mengimpor CSV. Buka sql/01_discovery.sql, pilih koneksi, dan jalankan query. Simpan investigasi lanjutan di file SQL tersebut atau file baru.

## Briefing

Ponte Commerce adalah perusahaan SIMULASI yang memakai data transaksi nyata Olist. Seluruh pernyataan stakeholder berikut adalah hipotesis latihan, bukan pernyataan resmi Olist.

Direktur Operations meminta prioritas perbaikan pengalaman pengiriman. Operations menduga persiapan seller lambat; Customer Experience menduga janji estimasi terlalu optimistis; Commercial mengkhawatirkan pembatasan seller akan mengurangi penjualan.

Tugas: ukur masalah, tentukan konsentrasinya, evaluasi kemungkinan penyebab, rekomendasikan prioritas dan rencana validasinya. Jangan menganggap keluhan atau penurunan sudah terbukti. Tidak ada angka target, biaya intervensi, atau keuntungan yang diasumsikan diketahui.

## Scope

Fokus utama: order dibeli pada 1 Januari sampai sebelum 1 Juli 2018. Database berisi SELURUH periode sumber agar konteks dan hasil pengiriman tidak hilang. Ini analisis retrospektif, bukan simulasi informasi yang tersedia tepat pada 30 Juni. Jangan menyimpulkan snapshot cutoff dari MAX satu tanggal event saja.

## Industry briefing

Marketplace menghubungkan seller dan pembeli. Pembayaran disetujui, barang diserahkan ke logistik, lalu diterima pembeli. Selisih timestamp menggambarkan interval tercatat, bukan otomatis kesalahan pihak tertentu. Satu order dapat mengandung banyak item dan seller; review dan pembayaran jangan diasumsikan satu baris per order.

## Evidence yang tersedia

orders: status, purchase timestamp, approval, carrier handover, customer delivery, estimated delivery.
order_items: item, produk, seller, shipping_limit_date, price dan freight_value.
customers/sellers: lokasi dan ID. customer_unique_id mengenali pembeli lintas order; customer_id adalah kunci relasi order.
products/product_category_name_translation: atribut serta kategori.
order_reviews: skor dan teks review, creation dan answer timestamps.
order_payments: pembayaran.
geolocation: koordinat prefix kode pos, tidak dijamin unik per prefix.

Tanggal estimasi perlu ditafsirkan sebagai janji tanggal atau timestamp secara eksplisit. shipping_limit_date berada di item; handover berada di order. Jelaskan keterbatasan atribusi untuk multi-seller. freight_value bukan bukti biaya internal maupun margin. Carrier ID, biaya perbaikan, margin, eksperimen, dan tracking rinci tidak tersedia.

## Pertanyaan yang perlu dijawab

1. Apa definisi keterlambatan dan denominator yang dipakai?
2. Bagaimana menangani order canceled, belum delivered, NULL, dan tanggal tidak konsisten?
3. Seberapa besar frekuensi dan tingkat keparahan masalah?
4. Segmen mana yang perlu diprioritaskan, dengan mempertimbangkan volume?
5. Tahap proses mana perlu diteliti lebih lanjut?
6. Apa hubungan delivery dan review, serta batas klaim kausalnya?
7. Apa alternatif tindakan, risiko, data tambahan, dan ukuran keberhasilan?

## Aturan mentor

Kamu memimpin investigasi. Hint 1 = pertanyaan kecil; Hint 2 = arah; Hint 3 = metode; Hint 4 = kerangka query; Rescue = bantu satu hambatan. Pertanyaan stakeholder boleh kapan saja. Mentor membedakan fakta sumber, asumsi simulasi, dan informasi tidak tersedia. Tidak ada satu tersangka atau jawaban bisnis wajib.

Misi pertama: catat keputusan yang diminta, tiga hipotesis, definisi KPI awal dan kebutuhan data. Lalu inspeksi schema dan grain. Kirim query serta interpretasi untuk direview.

## Penutupan dan penilaian

Isi deliverables/case_closure.md. Penilaian: framing 15, kualitas data/grain 20, analisis 25, rekomendasi dan alternatif 20, uncertainty 10, komunikasi/reproducibility 10. Bantuan dicatat terpisah; tidak dianggap kegagalan. Jangan membuat klaim penghematan aktual dari simulasi.
