//
//  PointChargeView.swift
//  Memorizing
//
//  Created by 진준호 on 2023/01/06.
//

import SwiftUI

struct PointChargeView: View {
    @EnvironmentObject var authStore: AuthStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack {
                    Text("100 P")
                        .font(.title)
                        .padding(.bottom, 2)
                    
                    Text("내 보유 포인트")
                        .font(.caption)
                        .foregroundColor(.gray2)
                }
                .frame(width: 120)
                .padding(.leading, 15)
                
                Rectangle()
                    .foregroundColor(.gray4)
                    .frame(width: 1, height: 50)
                    .padding(20)
                
                HStack {
                    VStack {
                        Image(systemName: "play.rectangle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                            .padding(.bottom, 2)
                        
                        Text("광고를 시청하고\n포인트를 모으세요")
                            .font(.caption)
                            .foregroundColor(.gray2)
                    }
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray4)
                }
                .frame(width: 135)
                
            }
            .padding()
            
            PointChargeButton(point: 1000)
            PointChargeButton(point: 3000)
            PointChargeButton(point: 5000)
            PointChargeButton(point: 10000)
            PointChargeButton(point: 30000)
            
            VStack(alignment: .leading) {
                Text("포인트 안내")
                    .font(.callout)
                    .padding(.top, 10)
                    .foregroundColor(.red)
                    .padding(.bottom, 1)
                
                Text("포인트 충전 후 7일 이내, 사용하지 않은 상품은 결제 취소가 가능합니다.\n포인트는 메모라이징의 암기장 구매에 사용됩니다.")
                    .font(.caption2)
            }
            .padding(.horizontal, 30)
        }
    }
}

struct PointChargeButton: View {
    @State private var isAlertToggle: Bool = false
    var point: Int
    var body: some View {
        
        Button {
            //
        } label: {
            ZStack {
                HStack {
                    Text("\(point) P")
                        .font(.title3)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("\(point) 원")
                        .font(.title3)
                        .foregroundColor(.black)
                }
                .zIndex(1)
                .frame(width: 270)
                
                Rectangle()
                    .frame(width: 312, height: 80)
                    .cornerRadius(10)
                    .foregroundColor(.gray5)
            }
            .padding(.leading, 30)
        }
        .alert(isPresented: $isAlertToggle) {
            Alert(title: Text("충전하기"),
                  message: Text("포인트를 충전하시겠습니까?"),
                  primaryButton: .destructive(Text("결제하기"),
                                              action: {
                // 포인트 올려주는 함수
            }), secondaryButton: .cancel(Text("취소")))
        }
    }
}

struct PointChargeView_Previews: PreviewProvider {
    static var previews: some View {
        PointChargeView()
            .environmentObject(AuthStore())
    }
}
