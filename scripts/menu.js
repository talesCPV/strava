function closeMenu(){
    try{
        document.getElementById('sidebar').classList.remove('open-sidebar');
        const ckb = document.querySelector('#sidebar_content').querySelectorAll('input[type=checkbox]')
        for(let i=0; i<ckb.length; i++){
            ckb[i].checked = 0
        }
    }catch{null}
}

function expirado(){
    return localStorage.getItem('access') !=0 && main_data.dashboard.data.expirado
}

function openMenu(){

    var drop = 0
    const data = new URLSearchParams();        
        data.append("hash", localStorage.getItem('hash'));

    const myPromisse = new Promise((resolve,reject) =>{
        fetch('config/menu.json')
        .then(function (response){        
            if (response.status === 200) { 
            resolve(response.text())
            } else {
                reject(new Error("Houve algum erro na comunicação com o servidor"))
            }
        })
    })


    myPromisse.then((resolve)=>{
        try{
            const menu_data = JSON.parse(resolve)          
            const menu = document.querySelector('#side_items')
            menu.innerHTML = ''//usr_menu
            pushMenu(menu, menu_data.itens)
            checkUserMail()
            checkUserSchedule()
            addShortcut()
            document.querySelector('#user-name').innerHTML = localStorage.getItem('nome')
            document.querySelector('#user-email').innerHTML = localStorage.getItem('email')
        }catch{            
/*
            localStorage.clear()
            this.location.reload(true)
*/            
        }
    })

    function pushMenu(menu, obj){
         
        for( let i=0; i<obj.length; i++){
            const li = document.createElement('li')
            li.className = 'side-item'
            li.classList.add(expirado() && obj[i].pg ? 'disabled' : 'enabled')
            li.title = obj[i].modulo

                const lbl = document.createElement('label')
                lbl.htmlFor = `drop-${drop}`
                lbl.classList = 'toggle'
                
                const icon = document.createElement('span')
                icon.className = `mdi ${obj[i].icone}`
                lbl.appendChild(icon)

                const desc = document.createElement('div')
                desc.className = 'item-description'

                const name_mod = document.createElement('span')
                name_mod.innerHTML = obj[i].modulo
                desc.appendChild(name_mod)

                lbl.appendChild(desc)

                li.appendChild(lbl)
                               
                const ckb = document.createElement('input')
                ckb.type = 'checkbox';
                ckb.id = `drop-${drop}`
                ckb.addEventListener('change',()=>{
                    document.querySelector('#sidebar').classList.add('open-sidebar')
                })
                drop++
                li.appendChild(ckb)
    
                if(obj[i].itens.length > 0){
                    const arrow = document.createElement('span')
                    arrow.className = 'mdi mdi-arrow-right-thick item-description'
                    desc.appendChild(arrow)

                    const ul = document.createElement('ul')  
                    ul.className = 'sub-menu'
                    pushMenu(ul,obj[i].itens)                                     
                    li.appendChild(ul)
                }else{
                    lbl.addEventListener('click',()=>{
                        main_data.dashboard.data.access = obj[i].access
                        openHTML(obj[i].link,obj[i].janela,obj[i].label,{},obj[i].width)
                        closeMenu()
                    })  
                }
          
            menu.appendChild(li)
        }
    }
}

