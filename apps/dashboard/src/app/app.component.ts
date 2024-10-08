import { Component, OnDestroy, OnInit, inject } from '@angular/core';
import { Router, RouterModule } from '@angular/router';

// import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { CommonModule } from '@angular/common';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatToolbarModule } from '@angular/material/toolbar';
import { Subscription } from 'rxjs';
import { UserService } from '@mfe-ws-1/data-access-user';
import { distinctUntilChanged } from 'rxjs/operators';

@Component({
  standalone: true,
  imports: [CommonModule, RouterModule, MatButtonModule, MatToolbarModule, MatIconModule],
  selector: 'ng-mf-root',
  styleUrls: ['./app.component.scss'],
  template: `
    <mat-toolbar color="primary">
  <button mat-icon-button (click)="toggleSidenav()">
    <mat-icon>menu</mat-icon>
  </button>
  <span>My Application</span>
  <span class="spacer"></span>
  <button mat-button>Home</button>
  <button mat-button>About</button>
  <button mat-button>Contact</button>
</mat-toolbar>
    <div class="dashboard-nav">Admin Dashboard</div>
    <div *ngIf="isLoggedIn$ | async; else signIn">
      You are authenticated so you can see this content.
    </div>
    <ng-template #signIn><router-outlet></router-outlet></ng-template>
  `,
})
export class AppComponent implements OnInit, OnDestroy {
  
  intervalId: any;
  sub:Subscription[] =[];
  
  ngOnDestroy(): void {
    if (this.intervalId) {
      clearInterval(this.intervalId);
    }
    if (this.sub?.length > 0) {
      this.sub.forEach((sub: Subscription) => sub.unsubscribe());
    }
  }
  private router = inject(Router);
  private userService = inject(UserService);
  isLoggedIn$ = this.userService.isUserLoggedIn$;
  title = "Welcome dashboard";

  toggleSidenav():void {
    console.log('toggle');
  }

  ngOnInit() {
    this.sub.push(
    this.isLoggedIn$
      .pipe(distinctUntilChanged())
      .subscribe(async (loggedIn) => {
        // Queue the navigation after initialNavigation blocking is completed
        this.intervalId = setTimeout(() => {
          if (!loggedIn) {
            this.router.navigateByUrl('login');
          } else {
            this.router.navigateByUrl('');
          }
        });
      })
    );
  }
}