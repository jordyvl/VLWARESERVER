if term.isColor() then
term.clear()
term.setCursorPos(1,1)
term.setTextColor(colours.yellow)
print"Goodbye"
sleep(3)
os.shutdown()
else
term.clear()
term.setCursorPos(1,1)
print"Goodbye"
sleep(3)
os.shutdown()
end