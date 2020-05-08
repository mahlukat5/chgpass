local mysql = exports.mysql


addCommandHandler("sifredegis",function(oyuncu,cmd,hesapismi,yenisifre)
	if not exports["integration"]:isPlayerScripter(oyuncu) then return end -- yetki koruması
	if not hesapismi then outputChatBox(oyuncu,"SYNTAX: /"..cmd.." <hesapismi> <yeni sifre>",oyuncu,255,0,0) return end
	if not yenisifre then outputChatBox(oyuncu,"SYNTAX: /"..cmd.." <hesapismi> <yeni sifre>",oyuncu,255,0,0) return end
	if changeAccountPassword(hesapismi,yenisifre) then
		outputChatBox(hesapismi.." isimli hesabın şifresi artık: "..yenisifre,oyuncu,0,255,0)
	else
		outputChatBox("Şifre değiştirilemedi.",oyuncu,255,0,0)
	end		
end)

addCommandHandler("sifremidegis",function(oyuncu,cmd,eskisifre,yenisifre)
	if not eskisifre then outputChatBox(oyuncu,"SYNTAX: /"..cmd.." <suanki sifren> <yeni sifren>",oyuncu,255,0,0) return end
	if not yenisifre then outputChatBox(oyuncu,"SYNTAX: /"..cmd.." <suanki sifren> <yeni sifren>",oyuncu,255,0,0) return end
	local accountID = getElementData(oyuncu,"account:id")
	if not accountID then return end
	local sorgu =  mysql:query("SELECT salt,password FROM `accounts` WHERE `id`='"..tostring(accountID).."'")
	if sorgu then
		local cevap = mysql:fetch_assoc(sorgu)
		mysql:free_result(sorgu)
		local salt,hesapsifre = cevap["salt"],cevap["password"]
		local cryptSifre = string.lower(md5(string.lower(md5(eskisifre))..salt))
		if cryptSifre == hesapsifre then
			local yeniCryptSifre = string.lower(md5(string.lower(md5(yenisifre))..salt))
			mysql:query_free("UPDATE accounts SET `password`='"..yeniCryptSifre.."' WHERE `id`='" ..tostring(accountID).. "'")
			outputChatBox("Şifren başarıyla değişti! Yeni şifren:"..yenisifre,oyuncu,0,255,0)
		else
			outputChatBox("Şifren eşleşmiyor!",oyuncu,255,0,0)
		end
	end
end)

function isAccountPassword(hesapismi,sifre)
	if not hesapismi then return false end
	if not sifre then return false end
	local sorgu =  mysql:query("SELECT salt,password FROM `accounts` WHERE `username`='"..tostring(hesapismi).."'")
	if sorgu then
		local cevap = mysql:fetch_assoc(sorgu)
		mysql:free_result(sorgu)
		local salt,hesapsifre = cevap["salt"],cevap["password"]
		local cryptSifre = string.lower(md5(string.lower(md5(sifre))..salt))
		return cryptSifre==hesapsifre
	else
		return false
	end
end
function changeAccountPassword(hesapismi,sifre)
	if not hesapismi then return false end
	if not sifre then return false end
	local sorgu =  mysql:query("SELECT salt FROM `accounts` WHERE `username`='"..tostring(hesapismi).."'")
	if sorgu then
		local cevap = mysql:fetch_assoc(sorgu)
		mysql:free_result(sorgu)
		local salt = cevap["salt"]
		local cryptSifre = string.lower(md5(string.lower(md5(sifre))..salt))
		mysql:query_free("UPDATE accounts SET `password`='"..cryptSifre.."' WHERE `username`='" ..tostring(hesapismi).. "'")
		return true
	else
		return false
	end
end
