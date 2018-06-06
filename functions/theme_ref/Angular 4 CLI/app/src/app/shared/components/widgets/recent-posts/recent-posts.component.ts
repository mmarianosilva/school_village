import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'widget-recent-posts',
  templateUrl: './recent-posts.component.html'
})
export class RecentPostsComponent implements OnInit {
  recentPostData:any;

  constructor() {
    this.recentPostData = [
      {
        user: 'David Villa Jacobs',
        post: 'Sorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam mattis lobortis sapien non posuere',
        avatar: './assets/demo/img/profile-pics/1.jpg'
      },
      {
        user: 'Candice Barnes',
        post: 'Quisque non tortor ultricies, posuere elit id, lacinia purus curabitur.',
        avatar: './assets/demo/img/profile-pics/2.jpg'
      },
      {
        user: 'Jeannette Lawson',
        post: 'Donec congue tempus ligula, varius hendrerit mi hendrerit sit amet. Duis ac quam sit amet leo feugiat iaculis',
        avatar: './assets/demo/img/profile-pics/3.jpg'
      },
      {
        user: 'Darla Mckinney',
        post: 'Duis tincidunt augue nec sem dignissim scelerisque. Vestibulum rhoncus sapien sed nulla aliquam lacinia',
        avatar: './assets/demo/img/profile-pics/4.jpg'
      },
      {
        user: 'Rudolph Perez',
        post: 'Phasellus a ullamcorper lectus, sit amet viverra quam. In luctus tortor vel nulla pharetra bibendum',
        avatar: './assets/demo/img/profile-pics/5.jpg'
      },
    ]
  }

  ngOnInit() {
  }

}
