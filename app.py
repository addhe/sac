from flask import Flask, render_template, request

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        try:
            # Ambil data dari form
            stocks = request.form.getlist('stocks[]')
            prices = request.form.getlist('prices[]')
            
            # Konversi ke float dan hitung total
            total_cost = 0
            total_shares = 0
            for i in range(len(stocks)):
                if stocks[i] and prices[i]:
                    total_shares += float(stocks[i])
                    total_cost += float(stocks[i]) * float(prices[i])
            
            # Hitung harga rata-rata
            average_price = total_cost / total_shares if total_shares > 0 else 0
            
            return render_template('index.html', result=average_price, total_shares=total_shares, total_cost=total_cost)
        except (ValueError, ZeroDivisionError) as e:
            return render_template('index.html', error=str(e))
    
    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True)
