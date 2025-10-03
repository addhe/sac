from flask import Flask, render_template, request

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        try:
            # Ambil data dari form
            stock_name = request.form.get('stock_name')
            current_lots = float(request.form.get('current_lots'))
            current_average = float(request.form.get('current_average'))
            new_lots = float(request.form.get('new_lots'))
            market_price = float(request.form.get('market_price'))

            # Konversi lot ke lembar saham (1 lot = 100 lembar)
            current_shares = current_lots * 100
            new_shares = new_lots * 100

            # Kalkulasi nilai investasi saat ini dan yang baru
            current_total_cost = current_shares * current_average
            new_total_cost = new_shares * market_price

            # Kalkulasi total saham dan total biaya baru
            total_shares = current_shares + new_shares
            total_cost = current_total_cost + new_total_cost

            # Hitung harga rata-rata baru
            new_average = total_cost / total_shares if total_shares > 0 else 0

            return render_template('index.html', result=True, 
                                 stock_name=stock_name,
                                 new_average=new_average, 
                                 total_shares=total_shares / 100, # Kirim kembali dalam lot
                                 total_cost=total_cost)
        except (ValueError, TypeError, ZeroDivisionError) as e:
            return render_template('index.html', error="Pastikan semua field diisi dengan angka yang valid.")
    
    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True)
