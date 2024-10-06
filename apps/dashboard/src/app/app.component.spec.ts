import { AppComponent } from './app.component';
import { NxWelcomeComponent } from './nx-welcome.component';
import { RouterModule } from '@angular/router';
import { TestBed } from '@angular/core/testing';

describe('AppComponent', () => {
  beforeEach(async () => {

    await TestBed.configureTestingModule({
      imports: [
        RouterModule.forRoot([{ path: '', component: NxWelcomeComponent }]),
        AppComponent,
        NxWelcomeComponent,
      ],
    }).compileComponents();
  });

  it('should create the app', () => {
    const fixture = TestBed.createComponent(AppComponent);
    const app = fixture.componentInstance;
    expect(app).toBeTruthy();
  });

  it(`should have as title 'Welcome dashboard'`, () => {
    const fixture = TestBed.createComponent(AppComponent);
    const app = fixture.componentInstance;
    expect(app.title).toEqual('Welcome dashboard');
  });

  // it('should render title', fakeAsync(() => {
  //   const fixture = TestBed.createComponent(AppComponent);
  //   const router = TestBed.inject(Router);
  //   fixture.ngZone?.run(() => router.navigate(['']));
  //   tick();
  //   fixture.detectChanges();
  //   const compiled = fixture.nativeElement as HTMLElement;
  //   expect(compiled.querySelector('h1')?.textContent).toContain(
  //     'Welcome dashboard'
  //   );
  // }));
});
