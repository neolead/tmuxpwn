# 🐲 WebPwn Tmux Panel Addon

Лёгкий плагин для tmux, который отображает в границе панелей ваш кастомный инфобар
![web](https://github.com/user-attachments/assets/967240e3-3462-41cf-937f-07d5d790329e)

## 🔧 Установка

1. **Скопировать файл**  
   ```bash
   cp webpwnchat.sh ~/.tmux/
   ```

2. **Сделать его исполняемым**  
   ```bash
   chmod +x ~/.tmux/webpwnchat.sh
   ```

3. **Подключить в `~/.tmux.conf`**  
   Откройте (или создайте) `~/.tmux.conf` и добавьте в конец:

   ```tmux
   # Включаем показ статуса по границе панели
   set -g pane-border-status bottom

   # Команда, которая будет рендерить панель (наш скрипт)
   set -g pane-border-format '#(~/.tmux/webpwnchat.sh)'

   # Включаем обычный статус-бар и задаём интервал обновления
   set -g status on
   set -g status-interval 2

   # Левый сегмент статус-бара: показываем имя сессии
   set -g status-left '[#S] '

   # Стиль границ панели
   set -g pane-border-style fg=colour240,bg=default

   # Увеличиваем историю прокрутки
   set -g history-limit 300000
   ```

4. **Применить изменения**  
   - **Перезапускаем tmux**:

   - Или внутри tmux:
     ```
     Prefix (Ctrl-b), затем :source-file ~/.tmux.conf
     ```

## 🚀 Готово!

Теперь ваша панель будет автоматически обновляться каждые 2 секунды, выводя содержимое `webpwnchat.sh`.  
Если нужно изменить поведение или стиль – правьте скрипт и/или параметры в `~/.tmux.conf`.  
