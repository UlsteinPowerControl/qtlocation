/****************************************************************************
**
** Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the Qt Mobility Components.
**
** $QT_BEGIN_LICENSE:LGPL$
** GNU Lesser General Public License Usage
** This file may be used under the terms of the GNU Lesser General Public
** License version 2.1 as published by the Free Software Foundation and
** appearing in the file LICENSE.LGPL included in the packaging of this
** file. Please review the following information to ensure the GNU Lesser
** General Public License version 2.1 requirements will be met:
** http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Nokia gives you certain additional
** rights. These rights are described in the Nokia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU General
** Public License version 3.0 as published by the Free Software Foundation
** and appearing in the file LICENSE.GPL included in the packaging of this
** file. Please review the following information to ensure the GNU General
** Public License version 3.0 requirements will be met:
** http://www.gnu.org/copyleft/gpl.html.
**
** Other Usage
** Alternatively, this file may be used in accordance with the terms and
** conditions contained in a signed written agreement between you and Nokia.
**
**
**
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

#ifndef QGEOROUTINGMANAGERENGINE_TEST_H
#define QGEOROUTINGMANAGERENGINE_TEST_H

#include <qgeoserviceprovider.h>
#include <qgeoroutingmanagerengine.h>
#include <QLocale>
#include <qgeoaddress.h>
#include <qgeoplace.h>
#include <qgeoroutereply.h>

#include <QDebug>
#include <QTimer>
#include <QTimerEvent>

QT_USE_NAMESPACE


class RouteReplyTest :public QGeoRouteReply
{
    Q_OBJECT

public:
    RouteReplyTest(QObject *parent=0) :QGeoRouteReply (QGeoRouteRequest(), parent)
    {}
    void  callSetError ( Error error, const QString & errorString ) {setError(error, errorString);}
    void  callSetFinished ( bool finished ) {setFinished(finished);}
    void  callSetRoutes(const QList<QGeoRoute> &routes) {setRoutes(routes);}

    void abort() {
        emit aborted();
    }
Q_SIGNALS:
    void aborted();
};

class QGeoRoutingManagerEngineTest: public QGeoRoutingManagerEngine
{
    Q_OBJECT
    RouteReplyTest* routeReply_;
    bool finishRequestImmediately_;
    int timerId_;
    QGeoRouteReply::Error errorCode_;
    QString errorString_;

public:
    QGeoRoutingManagerEngineTest(const QMap<QString, QVariant> &parameters,
        QGeoServiceProvider::Error *error, QString *errorString) :
        QGeoRoutingManagerEngine(parameters),
        routeReply_(0),
        finishRequestImmediately_(true),
        timerId_(0),
        errorCode_(QGeoRouteReply::NoError)
    {
        Q_UNUSED(error)
        Q_UNUSED(errorString)

        if (parameters.contains("gc_finishRequestImmediately")) {
            finishRequestImmediately_ = qvariant_cast<bool>(parameters.value("gc_finishRequestImmediately"));
        }

        setLocale(QLocale (QLocale::German, QLocale::Germany));
        setSupportedFeatureTypes (
                    QGeoRouteRequest::NoFeature | QGeoRouteRequest::TollFeature |
                    QGeoRouteRequest::HighwayFeature | QGeoRouteRequest::PublicTransitFeature |
                    QGeoRouteRequest::FerryFeature | QGeoRouteRequest::TunnelFeature |
                    QGeoRouteRequest::DirtRoadFeature | QGeoRouteRequest::ParksFeature |
                    QGeoRouteRequest::MotorPoolLaneFeature );
        setSupportedFeatureWeights (
                    QGeoRouteRequest::NeutralFeatureWeight | QGeoRouteRequest::PreferFeatureWeight |
                    QGeoRouteRequest::RequireFeatureWeight | QGeoRouteRequest::AvoidFeatureWeight |
                    QGeoRouteRequest::DisallowFeatureWeight );
        setSupportedManeuverDetails (
                    QGeoRouteRequest::NoManeuvers | QGeoRouteRequest::BasicManeuvers);
        setSupportedRouteOptimizations (
                    QGeoRouteRequest::ShortestRoute | QGeoRouteRequest::FastestRoute |
                    QGeoRouteRequest::MostEconomicRoute | QGeoRouteRequest::MostScenicRoute);
        setSupportedSegmentDetails (
                    QGeoRouteRequest::NoSegmentData | QGeoRouteRequest::BasicSegmentData );
        setSupportedTravelModes (
                    QGeoRouteRequest::CarTravel | QGeoRouteRequest::PedestrianTravel |
                    QGeoRouteRequest::BicycleTravel | QGeoRouteRequest::PublicTransitTravel |
                    QGeoRouteRequest::TruckTravel );
        setSupportsAlternativeRoutes ( true );
        setSupportsExcludeAreas ( true );
        setSupportsRouteUpdates ( true );
    }

    virtual QGeoRouteReply* calculateRoute(const QGeoRouteRequest& request)
    {
        routeReply_ = new RouteReplyTest();
        connect(routeReply_, SIGNAL(aborted()), this, SLOT(requestAborted()));

        if (request.numberAlternativeRoutes() > 70) {
            errorCode_ = (QGeoRouteReply::Error)(request.numberAlternativeRoutes() - 70);
            errorString_ = "error";
        } else {
            errorCode_ = QGeoRouteReply::NoError;
            errorString_ = "";
        }
        setRoutes(request, routeReply_);
        if (finishRequestImmediately_) {
            if (errorCode_) {
                routeReply_->callSetError(errorCode_, errorString_);
            } else {
                routeReply_->callSetError(QGeoRouteReply::NoError, "no error");
                routeReply_->callSetFinished(true);
            }
        } else {
            // we only allow serialized requests in QML - previous must have been aborted or finished
            Q_ASSERT(timerId_ == 0);
            timerId_ = startTimer(200);
        }
        return static_cast<QGeoRouteReply*>(routeReply_);
    }

    void setRoutes(const QGeoRouteRequest& request, RouteReplyTest* reply)
    {
        QList<QGeoRoute> routes;
        for (int i = 0; i < request.numberAlternativeRoutes(); ++i) {
            QGeoRoute route;
            route.setPath(request.waypoints());
            routes.append(route);
        }
        reply->callSetRoutes(routes);
    }

public Q_SLOTS:
    void requestAborted()
    {
        if (timerId_) {
            killTimer(timerId_);
            timerId_ = 0;
        }
        errorCode_ = QGeoRouteReply::NoError;
        errorString_ = "";
    }

protected:
     void timerEvent(QTimerEvent *event)
     {
         Q_ASSERT(timerId_ == event->timerId());
         Q_ASSERT(routeReply_);
         killTimer(timerId_);
         timerId_ = 0;
         if (errorCode_) {
             routeReply_->callSetError(errorCode_, errorString_);
             emit error(routeReply_, errorCode_, errorString_);
         } else {
             routeReply_->callSetError(QGeoRouteReply::NoError, "no error");
             routeReply_->callSetFinished(true);
             emit finished(routeReply_);
         }
     }
};

#endif