import os                                     # доступ к переменным окружения
import socket                                 # получение имени хоста и IP
from http.server import BaseHTTPRequestHandler, HTTPServer  # встроенный HTTP-сервер
# Порт берём из переменной окружения PORT, если её нет — используем 8080
PORT = int(os.environ.get("PORT", 8080))
class Handler(BaseHTTPRequestHandler):
    """Обработчик HTTP-запросов: вызывается на каждый входящий запрос."""
    
    def do_GET(self):
        # do_GET вызывается автоматически, когда приходит запрос методом GET
        if self.path == "/":
            hostname = socket.gethostname() # имя хоста: в kubernetes это имя пода
            try:
                ip = socket.gethostbyname(hostname) # определяем ip по имени хоста: в kubernetes это ip пода
            except socket.gaierror:
                ip = "unknown" # если имя не удалось превратить в ip, не роняем сервер
            
            # Формируем тело ответа и кодируем строку в байты (HTTP передаёт байты)
            body = f"Hello from Final-mikle\nHostname: {hostname}\nIP: {ip}\n".encode("utf-8")
            
            self.send_response(200)                                  # статус ответа 200 OK
            self.send_header("Content-Type", "text/plain; charset=utf-8")  # тип содержимого
            self.send_header("Content-Length", str(len(body)))       # длина тела в байтах
            self.end_headers()                                       # конец заголовков
            self.wfile.write(body)                                   # отправляем тело ответа
        else:
            self.send_error(404) # любой другой путь (например /abc) — отвечаем 404 not found
if __name__ == "__main__":
    # 0.0.0.0 — слушать на всех сетевых интерфейсах, а не только на localhost.
    # Без этого сервер внутри контейнера будет недоступен снаружи.
    server = HTTPServer(("0.0.0.0", PORT), Handler)
    print(f"Server started on port {PORT}", flush=True)  # flush=true — сразу выводим в логи
    server.serve_forever()                                # бесконечный цикл обработки запросов
