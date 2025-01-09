
function getPost(data,start,stop){

    const params = new Object;
        params.data = data
        params.start = start
        params.stop = stop
    const myPromisse = queryDB(params,'POST-0');
    myPromisse.then((resolve)=>{
        const json = JSON.parse(resolve)
        console.log(json)
        addPost(json)
    })

}

/*
        <div class="post">
            <div class="post-head">
                <div class="post-head-left">
                    <img class="post-head-img" src="assets/users/1/perfil.jpg" alt="">
                    <div class="post-head-name">Tales C. Dantas</div>
                </div>
                <div class="post-head-rigth">
                    <div class="post-btn">Subscribe</div>
                    <div class="btnMore">...</div>
                </div>
            </div>
            <div class="post-text">
                Lorem ipsum dolor sit amet. Id voluptas harum et ullam corrupti et doloremque rerum vel ipsa natus vel adipisci nisi. Et incidunt molestiae et ducimus incidunt in nostrum reiciendis ut veniam quia ea impedit perferendis in facere voluptatem 33 alias eaque. 
            </div>
            <img class="post-img" src="posts/img1.jpg" alt="">
            <div class="post-time">
                00:00 PM Oct-10,2024 - 200 Views
            </div>
            <div class="post-social">
                <div class="post-social-chat">
                    <span class="mdi mdi-chat-outline"></span>
                    <p>50</p>
                </div>
                <div class="post-social-like">
                    <span class="mdi mdi-thumb-up-outline"></span>
                    <p>15</p>
                </div>
                            
            </div>
        </div>
*/

function addPost(obj){

    const screen = document.querySelector('#content-screen')

    for(let i=0; i<obj.length; i++){
        console.log(obj[i])
        const post = document.createElement('div')
        post.className = 'post'

        const head = document.createElement('div')
        head.className = 'post-head'

        const head_left = document.createElement('div')
        head_left.className = 'post-head-left'

        const img = document.createElement('img')
        img.className = 'post-head-img'
        img.src = `assets/users/${obj[i].id_user}/perfil.jpg`
        head_left.appendChild(img)

        const head_name = document.createElement('div')
        head_name.className = 'post-head-name'
        head_name.innerHTML = obj[i].nome_usuario
        head_left.appendChild(head_name)
        head.appendChild(head_left)

        const head_rigth = document.createElement('div')
        head_rigth.className = 'post-head-left'

        const subs_btn = document.createElement('div')
        subs_btn.className = 'post-btn'
        subs_btn.innerHTML = 'Subscribe'
        head_rigth.appendChild(subs_btn)

        const btn_more = document.createElement('div')
        btn_more.className = 'btnMore'
        btn_more.innerHTML = '...'
        head_rigth.appendChild(btn_more)
        head.appendChild(head_rigth)
        post.appendChild(head)

        const post_text = document.createElement('div')
        post_text.className = 'post-text'
        post_text.innerHTML = obj[i].texto
        post.appendChild(post_text)

        const post_time = document.createElement('div')
        post_time.className = 'post-time'
        post_time.innerHTML = obj[i].cadastro
        post.appendChild(post_time)

        screen.appendChild(post)
    }


}